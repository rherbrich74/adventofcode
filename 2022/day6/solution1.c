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
        for (int i = 0; i < l - 4; i++) {
            /* ... and compare all 4*(4-1)/2=6 pairs; if they are all different, we are done! */
            if (buffer[i] != buffer[i + 1] && buffer[i] != buffer[i + 2] && buffer[i] != buffer[i + 3] &&
                buffer[i + 1] != buffer[i + 2] && buffer[i + 1] != buffer[i + 3] &&
                buffer[i + 2] != buffer[i + 3]) {
                    printf("Starting position: %d\n", i+4);
                    break;
            }
        }
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}