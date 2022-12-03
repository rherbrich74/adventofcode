/* --- Day 1: Calorie Counting ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256
#define MAX_ELVES 1000

int main(int argc, char *argv[])
{
    FILE *fp;
    char buffer[MAXLEN];
    int elf_cal[MAX_ELVES];
    int no_elves = 0;

    if (argc != 2)
    {
        printf("Usage: %s cal-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL)
    {
        int cur_cal_counter = 0;

        /* read the input file to the end */
        while (fgets(buffer, MAXLEN - 1, fp))
        {
            int val = atoi(buffer);

            if (val == 0)
            {
                /* copy the running counter */
                elf_cal[no_elves++] = cur_cal_counter;

                /* reset the current calorie counter */
                cur_cal_counter = 0;
            }
            else
            {
                cur_cal_counter += val;
            }
        }
        /* copy the running counter one final time */
        elf_cal[no_elves++] = cur_cal_counter;

        /* sort the calorie counters using bubble sort */
        for(int i = 0; i < no_elves; i++) {
            for (int j = i+1; j < no_elves; j++) {
                if (elf_cal[j] > elf_cal[i]) {
                    int tmp = elf_cal[i];
                    elf_cal[i] = elf_cal[j];
                    elf_cal[j] = tmp;
                }
            }
        }

        /* output the maximum count */
        printf("Maximum top three elf calories: %d\n", elf_cal[0] + elf_cal[1] + elf_cal[2]);
    }
    else
    {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}