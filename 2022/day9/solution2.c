/* --- Day 9: Rope Bridge ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256
#define MAX_TRACE_BUFFER 10000

/* stores all the positions of the tail */
static int tail_pos[MAX_TRACE_BUFFER][2];
static int no_tail_pos = 0;

/* adds another tail position (if it was not already in the list) */
void add_tail_pos(int tail_x, int tail_y) {
    /* search in the list if the tail position was already visited */
    int tail_pos_found = 0;
    for (int i = 0; i < no_tail_pos; i++) {
        if (tail_pos[i][0] == tail_x && tail_pos[i][1] == tail_y) {
            tail_pos_found = 1;
            break;
        }
    }

    if (!tail_pos_found) {
        if (no_tail_pos == MAX_TRACE_BUFFER) {
            printf("Buffer too small\n");
            exit(-4);
        }

        tail_pos[no_tail_pos][0] = tail_x;
        tail_pos[no_tail_pos][1] = tail_y;
        no_tail_pos++;
    }

    return;
}

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s path-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        int rope_x[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        int rope_y[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

        add_tail_pos(rope_x[9], rope_y[9]);

        /* read the path line-by-line and execute it */
        while (fgets(buffer, MAXLEN - 1, fp)) {
            if (strlen(buffer) < 3) {
                printf("Wrong format of path file: '%s'\n", buffer);
                return (-2);
            }

            /* extract direction and number of steps */
            char direction = buffer[0];
            int no_steps = atoi(&(buffer[2]));

            for (int i = 0; i < no_steps; i++) {
                /* execute the steps (first the head ... */
                switch (direction) {
                    case 'R':
                        rope_x[0] += 1;
                        break;
                    case 'L':
                        rope_x[0] -= 1;
                        break;
                    case 'U':
                        rope_y[0] += 1;
                        break;
                    case 'D':
                        rope_y[0] -= 1;
                        break;
                    default:
                        printf("Wrong format of direction ('R', 'L', 'U' or 'D' expected): '%c'\n", direction);
                        return (-3);
                }

                /* and then for all subsequent rope elements ... */
                for (int i = 1; i < 10; i++) {
                    if (abs(rope_x[i] - rope_x[i - 1]) <= 1 && abs(rope_y[i] - rope_y[i - 1]) <= 1) {
                        /* ... then there is no need to move the tail */
                        continue;
                    } else {
                        /* ... otherwise, move the tail closer to the head */
                        if (rope_x[i] == rope_x[i - 1]) {
                            /* ... either along the y-dimension (if the x-dimension is the same) */
                            rope_y[i] += (rope_y[i - 1] > rope_y[i]) ? +1 : -1;
                        } else if (rope_y[i] == rope_y[i - 1]) {
                            /* ... or the x-dimension (if the y-dimension is the same) */
                            rope_x[i] += (rope_x[i - 1] > rope_x[i]) ? +1 : -1;
                        } else {
                            /* ... or a diagonal move has to be made */
                            rope_x[i] += (rope_x[i - 1] > rope_x[i]) ? +1 : -1;
                            rope_y[i] += (rope_y[i - 1] > rope_y[i]) ? +1 : -1;
                        }
                    }
                }
                add_tail_pos(rope_x[9], rope_y[9]);
            }
        }
        printf("Unique tail position: %d\n", no_tail_pos);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}