#include <stdio.h>
#include "removeDig.h"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Arg. missing\n");
        return 0;
    }

    removeDig(argv[1]);
    printf("%s", argv[1]);
    printf("\n");
    return 0;
}
