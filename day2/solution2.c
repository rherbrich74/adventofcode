/* --- Day 2: Rock Paper Scissors ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256
#define MAX_MOVES 10000

int main(int argc, char *argv[])
{
    FILE *fp;
    char buffer[MAXLEN];
    char opp_move[MAX_MOVES];
    char outcome[MAX_MOVES];
    int no_moves = 0;

    if (argc != 2)
    {
        printf("Usage: %s rps-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL)
    {
        /* read the input file to the end */
        while (fgets(buffer, MAXLEN - 1, fp))
        {
            if (strlen(buffer) < 3)
            {
                printf("Incorrect format in line %d\n", no_moves);
                return (-1);
            }
            if (buffer[0] != 'A' && buffer[0] != 'B' && buffer[0] != 'C')
            {
                printf("Incorrect format: Opponent move should be one of 'A', 'B', and 'C'.\n");
                return (-2);
            }
            if (buffer[2] != 'X' && buffer[2] != 'Y' && buffer[2] != 'Z')
            {
                printf("Incorrect format: Outcome should be one of 'X', 'Y', and 'Z'.\n");
                return (-3);
            }
            opp_move[no_moves] = buffer[0] - 'A';
            outcome[no_moves] = buffer[2] - 'X';

            if (++no_moves == MAX_MOVES)
            {
                printf("Input file too long.\n");
                return (-4);
            }
        }

        /* compute the score across all moves */
        int score = 0;
        for (int i = 0; i < no_moves; i++)
        {
            int opp = opp_move[i];
            int me;
            switch (outcome[i])
            {
            case 0:
                me = (opp == 0) ? 2 : ((opp == 1) ? 0 : 1);
                break;
            case 1:
                me = opp;
                break;
            case 2:
                me = (opp == 0) ? 1 : ((opp == 1) ? 2 : 0);
                break;
            default:
                printf("Internal error\n");
            }

            int outcome_score = outcome[i] * 3;
            int shape_score = me + 1;
            score += (outcome_score + shape_score);
        }
        printf("Score: %d\n", score);
    }
    else
    {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}