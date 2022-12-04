/* --- Day 2: Rock Paper Scissors ---

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
        printf("Usage: %s rps-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the input file to the end and compute the score across all moves */
        int score = 0;
        while (fgets(buffer, MAXLEN - 1, fp)) {
            if (strlen(buffer) < 3) {
                printf("Incorrect format in line '%s'\n", buffer);
                return (-1);
            }
            if (buffer[0] != 'A' && buffer[0] != 'B' && buffer[0] != 'C') {
                printf("Incorrect format: Opponent move should be one of 'A', 'B', and 'C'.\n");
                return (-2);
            }
            if (buffer[2] != 'X' && buffer[2] != 'Y' && buffer[2] != 'Z') {
                printf("Incorrect format: My move should be one of 'X', 'Y', and 'Z'.\n");
                return (-3);
            }
            int opp = buffer[0] - 'A';
            int me = buffer[2] - 'X';

            int outcome_score = (me == opp) ? 3 : ((me == 0 && opp == 2) || (me == 2 && opp == 1) || (me == 1 && opp == 0)) ? 6 : 0;
            int shape_score = me + 1;

            score += (outcome_score + shape_score);
        }
        printf("Score: %d\n", score);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}