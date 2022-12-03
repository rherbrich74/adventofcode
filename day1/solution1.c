/* --- Day 1: Calorie Counting --- 

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN  256

int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    if (argc != 2) {
        printf ("Usage: %s cal-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        int max_cal = 0;
        int cur_cal_counter = 0;

        /* read the input file to the end */
        while (fgets(buffer, MAXLEN - 1, fp)) {
            int val = atoi(buffer);

            if (val == 0) {
                /* check if the running tally is bigger than the current maximum */
                if (cur_cal_counter > max_cal)
                    max_cal = cur_cal_counter;

                /* reset the current calorie counter */
                cur_cal_counter = 0;
            } else {
                cur_cal_counter += val;
            }
        }
        /* final check if the running tally is bigger than the current maximum */
        if (cur_cal_counter > max_cal)
            max_cal = cur_cal_counter;

        /* output the maximum count */
        printf("Maximum elf calories: %d\n", max_cal);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}