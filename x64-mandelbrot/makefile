CC = g++
CFLAGS = -no-pie -Wall -Wextra -pedantic -std=c++11
LDFLAGS = -lSDL2

all: main.o mandelbrot.o
	$(CC) $(CFLAGS) main.o mandelbrot.o -o fun $(LDFLAGS)

main.o: main.cpp
	$(CC) $(CFLAGS) -c main.cpp -o main.o

mandelbrot.o: mandelbrot.s
	nasm -f elf64 mandelbrot.s

clean:
	rm -f *.o
