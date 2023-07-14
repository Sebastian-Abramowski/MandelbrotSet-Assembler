CC=g++
CFLAGS=-m32 -Wall

all: main.o removeDig.o
	$(CC) $(CFLAGS) main.o removeDig.o -o fun

main.o: main.cpp
	$(CC) $(CFLAGS) -c main.cpp -o main.o

removeDig.o: removeDig.s
	nasm -f elf removeDig.s -o removeDig.o

clean:
	rm -f *.o
