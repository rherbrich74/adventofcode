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

        int visible_cnt = 0;
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                int hidden;

                /* check the north direction */
                hidden = 0;
                for (int k = j - 1; k >= 0; k--) {
                    if (map[i][k] >= map[i][j]) {
                        hidden = 1;
                        break;
                    }
                }
                if (!hidden) {
                    visible_cnt++;
                    continue;
                }

                /* check the east direction */
                hidden = 0;
                for (int k = i + 1; k < n; k++) {
                    if (map[k][j] >= map[i][j]) {
                        hidden = 1;
                        break;
                    }
                }
                if (!hidden) {
                    visible_cnt++;
                    continue;
                }

                // /* check the south direction */
                hidden = 0;
                for (int k = j + 1; k < n; k++) {
                    if (map[i][k] >= map[i][j]) {
                        hidden = 1;
                        break;
                    }
                }
                if (!hidden) {
                    visible_cnt++;
                    continue;
                }

                // /* check the west direction */
                hidden = 0;
                for (int k = i - 1; k >= 0; k--) {
                    if (map[k][j] >= map[i][j]) {
                        hidden = 1;
                        break;
                    }
                }
                if (!hidden) {
                    visible_cnt++;
                    continue;
                }
            }
        }

        printf("Visible fields: %d\n", visible_cnt);

        /* free all allocated memory */
        for (int i = 0; i < n; i++)
            free(map[i]);
        free(map);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}