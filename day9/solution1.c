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
        int head_x = 0;
        int head_y = 0;
        int tail_x = 0;
        int tail_y = 0;

        add_tail_pos(tail_x, tail_y);

        /* read the path line-by-line and execute it */
        while (fgets(buffer, MAXLEN - 1, fp)) {
            if (strlen(buffer) < 3) {
                printf("Wrong format of path file: '%s'\n", buffer);
                return (-2);
            }

            /* extract direction and number of steps */
            char direction = buffer[0];
            int no_steps = atoi(&(buffer[2]));

            /* execute the steps (first the head and then the tail) */
            for (int i = 0; i < no_steps; i++) {
                switch (direction) {
                    case 'R':
                        head_x += 1;
                        break;
                    case 'L':
                        head_x -= 1;
                        break;
                    case 'U':
                        head_y += 1;
                        break;
                    case 'D':
                        head_y -= 1;
                        break;
                    default:
                        printf("Wrong format of direction ('R', 'L', 'U' or 'D' expected): '%c'\n", direction);
                        return (-3);
                }

                /* check if the tail is touching the head, ... */
                if (abs(tail_x - head_x) <= 1 && abs(tail_y - head_y) <= 1) {
                    /* ... then there is no need to move the tail */
                    continue;
                } else {
                    /* ... otherwise, move the tail closer to the head */
                    if (tail_x == head_x) {
                        /* ... either along the y-dimension (if the x-dimension is the same) */
                        tail_y += (head_y > tail_y) ? +1 : -1;
                    } else if (tail_y == head_y) {
                        /* ... or the x-dimension (if the y-dimension is the same) */
                        tail_x += (head_x > tail_x) ? +1 : -1;
                    } else {
                        /* ... or a diagonal move has to be made */
                        tail_x += (head_x > tail_x) ? +1 : -1;
                        tail_y += (head_y > tail_y) ? +1 : -1;
                    }

                    add_tail_pos(tail_x, tail_y);
                }
            }
        }
        printf("Unique tail position: %d\n", no_tail_pos);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}