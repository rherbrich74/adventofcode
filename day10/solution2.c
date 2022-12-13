/* --- Day 10: Cathode-Ray Tube ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256

/* state variables of the simple VM */
static int no_cycles = 0;
static int x = 1;

/* increases the cycle count by one and plots a pixel */
void tick() {
    int column = no_cycles % 40;
    printf("%c", (column == x - 1 || column == x || column == x + 1) ? '#' : '.');
    if (++no_cycles % 40 == 0)
        printf("\n");
    return;
}

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s code-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the operations one by one and execute them */
        while (fgets(buffer, MAXLEN - 1, fp)) {
            if (!strncmp(buffer, "noop", 4)) {
                tick();
            } else if (!strncmp(buffer, "addx", 4)) {
                tick();
                tick();
                int i = atoi(&(buffer[4]));
                x += i;
            } else {
                printf("Wrong command: '%s'\n", buffer);
            }
        }
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}