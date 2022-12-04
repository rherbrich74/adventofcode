/* --- Day 3: Rucksack Reorganization ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256

int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    if (argc != 2) {
        printf("Usage: %s ruck-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the input file to the end and compute the score across all rucksacks */
        int score = 0;
        while (fgets(buffer, MAXLEN - 1, fp)) {
            /* remove trailing whitespaces */
            int i;
            for (i = strlen(buffer) - 1; i >= 0; i--) {
                if (buffer[i] != ' ' && buffer[i] != '\r' && buffer[i] != '\n' && buffer[i] != '\t')
                    break;
            }
            buffer[i+1] = '\0';

            /* check for validity of inputs */
            if (strlen(buffer) % 2 != 0) {
                printf("Incorrect format in line %s (number of items is odd)\n", buffer);
                return (-1);
            }
            for (char *p = buffer; *p; p++) {
                if (!((*p >= 'A' && *p <= 'Z') || (*p >= 'a' && *p <= 'z'))) {
                    printf("Invalid character %c in the string on line %s\n", *p, buffer);
                    return (-2);
                }
            }

            int used[256];
            int l = strlen(buffer) / 2;

            /* set each letter to no used (in fact, the whole ASCII set) */
            for (int j = 0; j < 256; j++) used[j] = 0;

            /* now first set all the letters used in the first half of the rucksack */
            for (int j = 0; j < l; j++)
                used[buffer[j]] = 1;

            /* and finally determine the which of the two items is repeated */
            char duplicate_item = 0;
            for (int j = l; j < 2*l; j++) {
                if (used[buffer[j]]) {
                    if (duplicate_item) {
                        printf("Internal error: The second half contains more than one duplication!\n");
                        return (-4);
                    }
                    duplicate_item = buffer[j];
                    break;
                }
            }
            if (!duplicate_item) {
                printf("Internal error: The second half contains no duplication!\n");
                return (-5);
            }
            score += (duplicate_item >= 'A' && duplicate_item <= 'Z') ? (duplicate_item - 'A' + 27) : (duplicate_item - 'a' + 1);
        }
        printf("Score: %d\n", score);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}