/* --- Day 8: Treetop Tree House ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s map-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the map line-by-line */
        if (!fgets(buffer, MAXLEN - 1, fp)) {
            printf("Could not read first line\n");
            return (-2);
        }

        int n = strlen(buffer) - 1;
        char **map;
        map = (char **)malloc(sizeof(char *) * n);
        for (int i = 0; i < n; i++) {
            map[i] = (char *)malloc(sizeof(char) * n);
            for (int j = 0; j < n; j++) map[i][j] = buffer[j] - '0';
            if ((i < n - 1) && !fgets(buffer, MAXLEN - 1, fp)) {
                printf("Missing line in the map\n");
                return (-2);
            }
        }

        int max_score = 0;
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (!(i == 0 || j == 0 || i == n - 1 || j == n - 1)) {
                    int score = 1, d;

                    /* check the north direction */
                    d = 1;
                    for (int k = j - 1; k > 0; k--, d++) {
                        if (map[i][k] >= map[i][j]) {
                            break;
                        }
                    }
                    score *= d;

                    /* check the east direction */
                    d = 1;
                    for (int k = i + 1; k < n-1; k++, d++) {
                        if (map[k][j] >= map[i][j]) {
                            break;
                        }
                    }
                    score *= d;

                    // /* check the south direction */
                    d = 1;
                    for (int k = j + 1; k < n-1; k++, d++) {
                        if (map[i][k] >= map[i][j]) {
                            break;
                        }
                    }
                    score *= d;

                    // /* check the west direction */
                    d = 1;
                    for (int k = i - 1; k > 0; k--, d++) {
                        if (map[k][j] >= map[i][j]) {
                            break;
                        }
                    }
                    score *= d;

                    max_score = (score > max_score) ? score : max_score;
                }
            }
        }

        printf("Maximum score: %d\n", max_score);

        /* free all allocated memory */
        for (int i = 0; i < n; i++)
            free(map[i]);
        free(map);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}