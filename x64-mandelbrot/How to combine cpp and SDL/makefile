CC = g++
CFLAGS = -Wall -Wextra -pedantic -std=c++11
LDFLAGS = -lSDL2

all: main.o
	$(CC) $(CFLAGS) main.o -o fun $(LDFLAGS)

main.o: main.cpp
	$(CC) $(CFLAGS) -c main.cpp -o main.o

clean:
	rm -f *.o
