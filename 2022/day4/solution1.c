/* --- Day 4: Camp Cleanup ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>

#define MAXLEN 256

int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    if (argc != 2) {
        printf("Usage: %s assgn-file\n", argv[0]);
        return (-1);
    }

    int fully_contained = 0;
    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the input file to the end */
        while (fgets(buffer, MAXLEN - 1, fp)) {
            int a1, a2, b1, b2;
            if (sscanf(buffer,"%d-%d,%d-%d", &a1, &a2, &b1, &b2) != 4) {
                printf("Incorrect format in line: '%s'\n", buffer);
                return (-1);
            }

            if ((a1 >= b1 && a2 <= b2) || /* either [a1,a2] is a full subset of [b1,b2], or ... */
                (b1 >= a1 && b2 <= a2))   /*  [b1,b2] is a full subset of [a1,a2] */
                fully_contained++;
        }
        printf("Containment in %d assignment pairs\n", fully_contained);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}