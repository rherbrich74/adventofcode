/* --- Day 6: Tuning Trouble ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 10000

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s msg-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the message */
        if (!fgets(buffer, MAXLEN - 1, fp)) {
            printf("Could not read message\n");
            return (-2);
        }

        /* cache the length of the message */
        int l = strlen(buffer);

        /* search starting from each character ... */
        for (int i = 0; i < l - 14; i++) {
            /* ... and compare all 14*(14-1)/2 pairs; unset the all_different flag as soon
            as any pair is the same */
            int all_different = 1;
            for (int j = 0; j < 14; j++) {
                for (int k = j + 1; k < 14; k++) {
                    if (buffer[i + j] == buffer[i + k]) {
                        all_different = 0;
                        goto end;
                    }
                }
            }
        end:

            /* if they are all different, the starting position has been found */
            if (all_different) {
                printf("Starting position: %d\n", i + 14);
                break;
            }
        }
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}