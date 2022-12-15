/* --- Day 13: Distress Signal ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256

typedef struct intList_ {
    int length;         /* length of the list */
    char is_scalar;     /* flags if the list if a scalar (in this case, length==1) */
    union {
        int int_value;                  /* value of the single item list */
        struct intList_ **values;       /* list of pointers to */
    };
} intList;

/* creates a new empty list */
intList *new_intList() {
    intList* il = (intList *) malloc (sizeof(intList));
    il->length = 0;
    il->is_scalar = 0;
    il->int_value = 0;

    return(il);
}

/* creates a new list with a singleton integer */
intList *new_intList_from_int(int i) {
    intList* il = (intList *) malloc (sizeof(intList));
    il->length = 1;
    il->is_scalar = 1;
    il->int_value = i;

    return(il);
}

/* creates a new list with a singleton integer List */
void add_intList(intList *il, intList *ill) {
    il->is_scalar = 0;
    if (il->length == 0)
        il->values = (intList **) malloc (sizeof(intList *));
    else
        il->values = (intList **) realloc (il->values, sizeof(intList *) * (il->length + 1));
    il->values[il->length++] = ill;

    return;
}

/* parses a new list of integers from the buffer at a start position */
intList *parse_intList(const char *buffer, int *start_pos) {
    intList *il;

    switch(buffer[*start_pos]) {
        case '[':
            il = new_intList();
            *start_pos++;
            do {
                add_intList(il, parse_intList(buffer, start_pos));
                *start_pos++;
            } while (buffer[*start_pos] == ',');
            if (buffer[*start_pos] != ']') {
                printf("] expect at %s\n", &(buffer[*start_pos]));
                exit(-2);
            }
            break;
        default:
            
    }
}

void print_intList(intList *il) {
    if (il->is_scalar)
        printf("%d", il->int_value);
    else {
        printf("[");
        for(int i = 0; i < il->length; i++) {
            print_intList(il->values[i]);
            if(i < il->length-1) printf(",");
        }
        printf("]");
    }

    return;
}

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s lst-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        // intList *il = new_intList();
        // intList *il1 = new_intList();        
        // intList *il2 = new_intList();        
        // add_intList(il1,new_intList_from_int(1));
        // add_intList(il2,new_intList_from_int(2));
        // add_intList(il2,new_intList_from_int(3));
        // add_intList(il2,new_intList_from_int(4));
        // add_intList(il,il1);
        // add_intList(il,il2);

        // print_intList(il);
        // printf("\n");
        while (fgets(buffer, MAXLEN - 1, fp)) {
            intList *il1 = parse_intList(buffer);
        }
   } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}