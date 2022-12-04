/* --- Day 3: Rucksack Reorganization ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256

int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[3][MAXLEN];

    if (argc != 2) {
        printf("Usage: %s ruck-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the input file to the end and compute the score across all rucksacks */
        int score = 0;
        while (fgets(buffer[0], MAXLEN - 1, fp)) {
            /* read the next two lines for the block-of-three */
            if (fgets(buffer[1], MAXLEN - 1, fp) == 0 || fgets(buffer[2], MAXLEN - 1, fp) == 0) {
                printf ("Number of rucksacks must be a multiple of three.\n");
                return (-4);
            }

            /* pre-process and validate all three rucksacks */
            for(int k = 0; k < 3; k++) {
                /* remove trailing whitespaces */
                int i;
                for (i = strlen(buffer[k]) - 1; i >= 0; i--) {
                    if (buffer[k][i] != ' ' && buffer[k][i] != '\r' && buffer[k][i] != '\n' && buffer[k][i] != '\t')
                        break;
                }
                buffer[k][i+1] = '\0';

                /* check for validity of inputs */
                if (strlen(buffer[k]) % 2 != 0) {
                    printf("Incorrect format in line '%s' (number of items is odd)\n", buffer[k]);
                    return (-1);
                }
                for (char *p = buffer[k]; *p; p++) {
                    if (!((*p >= 'A' && *p <= 'Z') || (*p >= 'a' && *p <= 'z'))) {
                        printf("Invalid character %c in the string on line '%s'\n", *p, buffer[k]);
                        return (-2);
                    }
                }
            }

            int used_cnt[256];

            /* set each letter to used zero times (in fact, the whole ASCII set) */
            for (int j = 0; j < 256; j++) used_cnt[j] = 0;

            /* process the next batch of 3 rucksacks */
            for (int k = 0; k < 3; k++) {
                int used[256];

                /* set each letter to not used (in fact, the whole ASCII set) */
                for (int j = 0; j < 256; j++) used[j] = 0;

                /* now first set all the letters used in the first half of the rucksack */
                for (int l = 0; l < strlen(buffer[k]); l++)
                    used[buffer[k][l]] = 1;

                /* now increment the used count for all used letters */
                for (int j = 0; j < 256; j++) used_cnt[j] += used[j];
            }

            char badge_item = 0;
            for (int j = 0; j < 256; j++) {
                if (used_cnt[j] == 3) {
                    if (badge_item) {
                        printf("Internal error: There is more than one item that is contained in all rucksacks!\n");
                        return (-4);
                    }
                    badge_item = j;
                    break;
                }
            }
            if (!badge_item) {
                printf("Internal error: The 3 rucksacks contain no common item!\n");
                return (-5);
            }
            score += (badge_item >= 'A' && badge_item <= 'Z') ? (badge_item - 'A' + 27) : (badge_item - 'a' + 1);
        }
        printf("Score: %d\n", score);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}