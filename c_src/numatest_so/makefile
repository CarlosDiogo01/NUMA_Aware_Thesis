# the compiler: gcc for C program, define as g++ for C++
CC = g++

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -Wall -pthread -lboost_threads -lnuma

# Optimization Level (O2, O3 ...)
OPTLEVEL = -O0

# the build target executable:
TARGET=numatest

all: $(TARGET)

$(TARGET): $(TARGET).cpp
	$(CC) $(OPTLEVEL) $(CFLAGS) -o $(TARGET) $(TARGET).cpp


clean:
	$(RM) $(TARGET)
