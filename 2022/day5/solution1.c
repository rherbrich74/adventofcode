/* --- Day 5: Supply Stacks ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256
#define MAX_STACKS 100
#define MAX_HEIGHT 100

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];
    char stacks[MAX_STACKS][MAX_HEIGHT];
    int no_stacks = -1;
    int stack_height[MAX_STACKS];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s stack-file\n", argv[0]);
        return (-1);
    }

    /* initialize all stacks to zero height */
    for (int i = 0; i < MAX_STACKS; i++) stack_height[i] = 0;

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the stacks */
        do {
            /* check that there is still a line to read */
            if (!fgets(buffer, MAXLEN - 1, fp)) {
                printf("Stack reading not finished yet\n");
                return (-1);
            }

            /* provided that this is not the index line */
            if (buffer[1] != '1') {
                int s = strlen(buffer) / 4;
                if (no_stacks == -1) {
                    if (s > MAX_STACKS - 1) {
                        printf ("Not enough storage for the actual number of stacks\n");
                        return (-2);
                    }
                    no_stacks = s;
                }
                else {
                    if (s != no_stacks) {
                        printf ("Internal error: different number of stacks across lines\n");
                        return (-3);
                    }
                }

                for (int i = 0; i < no_stacks; i++) {
                    if (buffer[i*4] == '[') {
                        stacks[i+1][stack_height[i+1]++] = buffer[i*4+1];
                    } else {
                        if (stack_height[i+1] != 0) {
                            printf("Internal error: Stack %d has a hole\n", i+1);
                            return (-4);
                        }
                    }
                }
            }
        } while (buffer[1] != '1');

        /* reverse all stacks after reading them */
        for (int i = 1; i <= no_stacks; i++) {
            for (int j = 0; j < stack_height[i] / 2; j++) {
                char tmp = stacks[i][j];
                stacks[i][j] = stacks[i][stack_height[i] - j - 1];
                stacks[i][stack_height[i] - j - 1] = tmp;
            }
        }

        /* check that there is still a line to read */
        if (!fgets(buffer, MAXLEN - 1, fp)) {
            printf("Expecting two lines until the move list is processed\n");
            return (-1);
        }

        /* process the move list */
        while (fgets(buffer, MAXLEN - 1, fp)) {
            int cnt, from, to;
            if (sscanf(buffer, "move %d from %d to %d", &cnt, &from, &to) != 3) {
                printf ("Wrong format of move list\n");
                return (-5);
            }

            /* move one crate one-by-one */
            for (int j = 0; j < cnt; j++)
                stacks[to][stack_height[to]++] = stacks[from][--stack_height[from]];
        }

        /* print the final head pieces as a string */
        for (int i = 1; i <= no_stacks; i++)
            printf("%c", stacks[i][stack_height[i] - 1]);
        printf("\n");
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}