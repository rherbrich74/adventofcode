/* --- Day 5: Supply Stacks ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>

#define MAXLEN 256

int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    if (argc != 2) {
        printf("Usage: %s stack-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the input file to the end */
        while (fgets(buffer, MAXLEN - 1, fp)) {
        }
        // printf("Containment in %d assignment pairs\n", fully_contained);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}