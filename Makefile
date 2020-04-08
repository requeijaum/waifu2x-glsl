# ©2017-2018 YUICHIRO NAKADA

PROGRAM = waifu2x_glsl

CC	= clang
CPP	= clang++
#CFLAGS  = -Ofast -march=native -funroll-loops -mf16c -DDEBUG
CFLAGS  = -v -Ofast -march=native -funroll-loops -mf16c
CPPFLAGS= $(CFLAGS)
LDFLAGS	= -lm
CSRC	= $(wildcard *.c)
CPPSRC	= $(wildcard *.cpp)
DEPS	= $(wildcard *.h) Makefile
OBJS	= $(patsubst %.c,%.o,$(CSRC)) $(patsubst %.cpp,%.o,$(CPPSRC))

#USE_GLES:= 1
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	#CC := $(shell [ -x /usr/bin/diet ] && echo diet clang)
ifeq ($(USE_GLES),1)
	CFLAGS  += `pkg-config --cflags glesv2 egl gbm` -DGPGPU_USE_GLES
	LDFLAGS	+= `pkg-config --libs glesv2 egl gl gbm`
else
	CFLAGS  += `pkg-config --cflags gl`
	LDFLAGS	+= `pkg-config --libs gl -lglfw`
endif
endif
ifeq ($(UNAME_S),Darwin)
	CFLAGS  += -L/opt/local/lib -I/opt/local/include
	LDFLAGS	+= -framework OpenGL -lglfw -L/opt/local/lib -I/opt/local/include
	# using MacPorts' GLFW - using El Capitan 10.11.5
endif

%.o: %.cpp $(DEPS)
	$(CPP) -c -o $@ $< $(CPPFLAGS)

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(PROGRAM): $(OBJS)
	$(CPP) -o $@ $^ -s $(LDFLAGS)

.PHONY: clean
clean:
	$(RM) $(PROGRAM) $(OBJS) *.o *.s
