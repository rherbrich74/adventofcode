/* --- Day 13: Distress Signal ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256

typedef struct intList_ {
    int length;     /* length of the list */
    char is_scalar; /* flags if the list if a scalar (in this case, length==1) */
    union {
        int int_value;            /* value of the single item list */
        struct intList_ **values; /* list of pointers to */
    };
} intList;

/* creates a new empty list */
intList *new_intList() {
    intList *il = (intList *)malloc(sizeof(intList));
    il->length = 0;
    il->is_scalar = 0;
    il->values = NULL;
    return (il);
}

/* creates a new list with a singleton integer */
intList *new_intList_from_int(int i) {
    intList *il = (intList *)malloc(sizeof(intList));
    il->length = 1;
    il->is_scalar = 1;
    il->int_value = i;

    return (il);
}

/* frees the memory of the int list */
void delete_intList(intList *il) {
    if (il && !il->is_scalar) {
        for (int i = 0; i < il->length; i++)
            delete_intList(il->values[i]);
        if (il->values) free(il->values);
    }
    return;
}

/* creates a new list with a singleton integer List */
void add_intList(intList *il, intList *ill) {
    il->is_scalar = 0;
    if (il->length == 0)
        il->values = (intList **)malloc(sizeof(intList *));
    else
        il->values = (intList **)realloc(il->values, sizeof(intList *) * (il->length + 1));
    il->values[il->length++] = ill;

    return;
}

/* parses a new list of integers from the buffer at a start position */
intList *parse_intList(const char *buffer, int *start_pos) {
    intList *il;
    char b[256];
    int i;

    switch (buffer[*start_pos]) {
        case '[':
            /* if the list starts with square brackets ... */
            il = new_intList();
            do {
                /* ... then parse the list until the next character is not a separating comma */
                (*start_pos)++;
                add_intList(il, parse_intList(buffer, start_pos));
            } while (buffer[*start_pos] == ',');
            if (buffer[*start_pos] != ']') {
                printf("] expect at %s\n", &(buffer[*start_pos]));
                exit(-2);
            }
            (*start_pos)++;
            break;
        default:
            /* ... otherwise parse the single integer */
            for (i = 0; buffer[*start_pos] >= '0' && buffer[*start_pos] <= '9'; i++, (*start_pos)++)
                b[i] = buffer[*start_pos];
            b[i] = '\0';
            il = new_intList_from_int(atoi(b));
            break;
    }

    return (il);
}

/* prints an int List on the screen */
void print_intList(intList *il) {
    if (il->is_scalar)
        printf("%d", il->int_value);
    else {
        printf("[");
        for (int i = 0; i < il->length; i++) {
            print_intList(il->values[i]);
            if (i < il->length - 1) printf(",");
        }
        printf("]");
    }

    return;
}

/* compares two int lists */
int compare_intList(intList *il1, intList *il2) {
    /* If both values are integers, the lower integer should come first */
    if (il1->is_scalar && il2->is_scalar)
        return il2->int_value - il1->int_value;
    else if (!il1->is_scalar && !il2->is_scalar) {
        /* If both values are lists, compare the first value of each list, then the second value, and so on ... */
        for (int i = 0; i < il1->length && i < il2->length; i++) {
            int ret = compare_intList(il1->values[i], il2->values[i]);
            if (ret)
                return (ret);
        }
        return (il2->length - il1->length);
    } else {
        /* If exactly one value is an integer, convert the integer to a list which contains that integer as its only value, then retry the comparison */
        intList *il_tmp = new_intList();
        add_intList(il_tmp,(il1->is_scalar) ? new_intList_from_int(il1->int_value) : new_intList_from_int(il2->int_value));
        int ret = (il1->is_scalar) ? compare_intList(il_tmp, il2) : compare_intList(il1, il_tmp);
        delete_intList(il_tmp);
        free(il_tmp);
        return ret;
    }

    /* we should never get here */
    printf("We should never get here ...\n");
    exit(-3);

    return (0);
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
        int s = 0;
        intList *il1 = parse_intList("[1,[1,2,[4,5,6]],3,1,1]", &s);
        s = 0;
        intList *il2 = parse_intList("[[1],[1,2,[4,5,6]],3,1,1]", &s);
        print_intList(il1);
        printf("\n");
        print_intList(il2);
        printf("\n%d\n", compare_intList(il1, il2));
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}