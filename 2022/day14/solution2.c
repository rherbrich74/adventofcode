/* --- Day 14: Regolith Reservoir ---

2022 written by Ralf Herbrich
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 1024

/* defines the map dimensions */
#define MAX_X 1000
#define MAX_Y 1000

/* defines an enum for the map elements */
typedef enum { FREE,
               WALL,
               SAND } map_elem_t;

/* read the map from a stream */
map_elem_t **read_map(FILE *fp) {
    char buffer[MAXLEN];
    int max_y = 0;

    /* allocate the map */
    map_elem_t **map = (map_elem_t **)malloc(sizeof(map_elem_t *) * MAX_X);
    for (int i = 0; i < MAX_X; i++) {
        map[i] = (map_elem_t *)malloc(sizeof(map_elem_t) * MAX_Y);
        for (int j = 0; j < MAX_Y; j++) {
            map[i][j] = FREE;
        }
    }

    /* read the input file line-by-line and draw the wall */
    while (fgets(buffer, MAXLEN - 1, fp)) {
        int last_x = -1, last_y = -1; /* previous coordinates */
        int new_x, new_y;             /* new coordinates */
        char *p = buffer;             /* pointer to the current character parsed */
        while (sscanf(p, "%d,%d", &new_x, &new_y) == 2) {
            /* check that we are not exceeding the dimensions of the map */
            if (new_x >= MAX_X || new_y >= MAX_Y) {
                printf("Coordinates too big: (%d,%d)\n", new_x, new_y);
                exit(-2);
            }

            /* update the maximum y coordinate */
            max_y = (new_y > max_y) ? new_y : max_y;

            /* if this is the second coordinate, then draw a wall */
            if (last_x != -1 && last_y != -1) {
                if (new_x == last_x) {
                    if (new_y > last_y)
                        for (int y = last_y; y <= new_y; y++)
                            map[new_x][y] = WALL;
                    else
                        for (int y = new_y; y <= last_y; y++)
                            map[new_x][y] = WALL;
                } else {
                    if (new_x > last_x)
                        for (int x = last_x; x <= new_x; x++)
                            map[x][new_y] = WALL;
                    else
                        for (int x = new_x; x <= last_x; x++)
                            map[x][new_y] = WALL;
                }
            }

            /* advance pointer to the next character after the two digits */
            while (isdigit(*p) || *p == ',') p++;

            if (isblank(*p))
                p += 4;

            /* copy coordinates */
            last_x = new_x;
            last_y = new_y;
        }
    }

    /* add one more line at the bottom of the map */
    for(int x = 0; x < MAX_X; x++)
        map[x][max_y+2] = WALL;

    /* return the map read from the stream */
    return (map);
}

/* simulate the pouring of a grain of sand;
   returns 0 if the sand falls to the abyss (that is, terminal y is <0) */
int pour_grain_of_sand(map_elem_t **map) {
    int grain_x = 500;
    int grain_y = 0;

    /* enter an endless loop; if we exit this loop, the sand has not moved anymore */
    while (1) {
        /* check if we are about to move off the grid */
        if (grain_y == MAX_Y - 1 || map[grain_x][grain_y] == SAND) {
            return (0); /* in this case, the pour is infinite or blocked */
        }

        /* now check if we can still move the grain */
        if (map[grain_x][grain_y + 1] == FREE) {
            grain_y++;
        } else if (map[grain_x - 1][grain_y + 1] == FREE) {
            grain_x--;
            grain_y++;
        } else if (map[grain_x + 1][grain_y + 1] == FREE) {
            grain_x++;
            grain_y++;
        } else {
            map[grain_x][grain_y] = SAND;
            return (1); /* in this case, the grain has stopped moving */
        }
    }
    printf("Internal error: We should never get here!\n");
    return (1);
}

/* prints the map on the screen */
void print_map(map_elem_t **map, int min_x, int max_x, int min_y, int max_y) {
    for (int y = min_y; y <= max_y; y++) {
        for (int x = min_x; x <= max_x; x++)
            printf("%c", (map[x][y] == FREE) ? '.' : (map[x][y] == WALL) ? '#'
                                                                         : 'o');
        printf("\n");
    }
    return;
}

/* free the memory of the map */
void delete_map(map_elem_t **map) {
    for (int i = 0; i < MAX_X; i++)
        free(map[i]);
    free(map);

    return;
}

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s map-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the map from the stream */
        map_elem_t **map = read_map(fp);

        /* now count the number of grains we can pour on the map */
        int score = 0;
        while (pour_grain_of_sand(map)) {
            score++;
        }
        printf("Score: %d\n", score);

        /* free the memory for the map */
        delete_map(map);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}