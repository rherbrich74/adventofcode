/* --- Day 11: Monkey in the Middle ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256
#define MAX_PROGS 10

/* defines a new type for list of long long integer values */
typedef struct longLongList_ {
    int length;
    int size;
    long long *values;
} longLongList;

/* creates an empty list of long long integers */
longLongList *new_longLongList() {
    longLongList *lll = (longLongList *)malloc(sizeof(longLongList));
    lll->length = 0;
    lll->size = 0;
    lll->values = NULL;
    return (lll);
}

/* deletes all memory that makes up a long long integer list */
void delete_longLongList(longLongList *lll) {
    if (lll->values) {
        free(lll->values);
        lll->values = NULL;
    }
    lll->size = 0;
    lll->length = 0;
    return;
}

/* prints a long long integer list on the screen */
void print_longLongList(longLongList *lll) {
    for (int i = 0; i < lll->length; i++) {
        printf("%lld", lll->values[i]);
        if (i < lll->length - 1)
            printf(",");
    }

    return;
}

/* returns the length of the long long integer list */
int get_length_longLongList(longLongList *lll) {
    return (lll->length);
}

/* returns the ith item from a long long integer list */
long long get_item_longLongList(longLongList *lll, int idx) {
    if (idx >= lll->length) {
        printf("Incorrect index access: %d", idx);
        print_longLongList(lll);
        printf("\n");
        exit(-1);
    }
    return (lll->values[idx]);
}

/* adds an element to the end of the list */
void add_elem_longLongList(longLongList *lll, long long l) {
    /* re-allocate memory for the additional element, if necessary */
    if (lll->length == lll->size) {
        if (lll->size > 0) {
            lll->values = (long long *)realloc(lll->values, sizeof(long long) * (lll->size * 2));
            lll->size *= 2;
        } else {
            lll->values = (long long *)malloc(sizeof(long long));
            lll->size = 1;
        }
    }

    lll->values[lll->length++] = l;
    return;
}

/* removes the last element from a list */
void remove_last_elem_longLongList(longLongList *lll) {
    /* re-allocate memory for the additional element */
    if (lll->length > 0)
        lll->length--;

    return;
}

/* makes a deep copy of a long long integer list */
longLongList *copy_longLongList(longLongList *src) {
    longLongList *dest = new_longLongList();
    for (int i = 0; i < src->length; i++) {
        add_elem_longLongList(dest, get_item_longLongList(src, i));
    }

    return (dest);
}

/* defines the three types of monkey operation */
typedef enum monkeyOp_ { ADD_CONST,
                         MUL_CONST,
                         SQUARE } monkeyOp;

/* defines a new monkey program */
typedef struct monkeyProgram_ {
    int index;                    /* the index of the monkey */
    longLongList *starting_items; /* the starting items */
    monkeyOp op;                  /* operation in each cycle */
    int op_value;                 /* additional const value of the monkey operation */
    int divisible_test;           /* the number that the worry level needs to be divisible by */
    int target_monkey_true;       /* monkey that receives the items when the test is true */
    int target_monkey_false;      /* monkey that receives the items when the test is false */
} monkeyProgram;

/* defines a monkey state */
typedef struct monkeyState_ {
    int no_items_processed; /* number of items processed */
    longLongList *items;    /* current list of items to be processed by monkey */
} monkeyState;

/* reads a monkey program from a file and returns the index of the monkey
   (or -1 if it could not read a program) */
monkeyProgram *read_monkey_program(FILE *fp) {
    int i;
    char c;
    char buffer[MAXLEN];

    /* allocate the monkey program */
    monkeyProgram *prog = (monkeyProgram *)malloc(sizeof(monkeyProgram));

    /* read monkey index */
    if (fscanf(fp, "Monkey %d:", &prog->index) != 1) {
        free(prog);
        return NULL;
    }

    /* read the list of starting items */
    prog->starting_items = new_longLongList();
    if (fscanf(fp, "  Starting items: ") != 0) {
        printf("Expecting at least one starting item\n");
        exit(-3);
    }
    do {
        fscanf(fp, "%d%c", &i, &c);
        add_elem_longLongList(prog->starting_items, i);
    } while (c == ',');

    /* parse the operation */
    if (!fgets(buffer, MAXLEN - 1, fp)) {
        printf("Expecting a monkey operation\n");
        exit(-4);
    }
    if (sscanf(buffer, "  Operation: new = old + %d", &prog->op_value) == 1) {
        prog->op = ADD_CONST;
    } else if (sscanf(buffer, "  Operation: new = old * %d", &prog->op_value) == 1) {
        prog->op = MUL_CONST;
    } else if (sscanf(buffer, "  Operation: new = old * old") == 0) {
        prog->op = SQUARE;
    } else {
        printf("Unrecognized monkey operation: %s\n", buffer);
        exit(-5);
    }

    /* parse the test */
    if (fscanf(fp, "  Test: divisible by %d\n", &prog->divisible_test) != 1) {
        printf("Expecting a monkey operation test\n");
        exit(-6);
    }

    /* parse the 'then' and 'else' branch of the test */
    if (fscanf(fp, "    If true: throw to monkey %d\n", &prog->target_monkey_true) != 1) {
        printf("Expecting a target monkey when test is true\n");
        exit(-7);
    }
    if (fscanf(fp, "    If false: throw to monkey %d\n", &prog->target_monkey_false) != 1) {
        printf("Expecting a target monkey when test is false\n");
        exit(-8);
    }

    return (prog);
}

/* frees the memory of a monkey program */
void delete_monkey_program(monkeyProgram *prog) {
    if (prog->starting_items) {
        delete_longLongList(prog->starting_items);
        free(prog->starting_items);
    }

    return;
}

/* prints a monkey program on the screen */
void print_monkey_program(monkeyProgram *prog) {
    printf("Monkey %d:\n", prog->index);

    /* print starting items */
    printf("  Starting items: ");
    print_longLongList(prog->starting_items);
    printf("\n");

    /* print the operation */
    printf("  Operation: ");
    switch (prog->op) {
        case ADD_CONST:
            printf(" new = old + %d\n", prog->op_value);
            break;
        case MUL_CONST:
            printf(" new = old * %d\n", prog->op_value);
            break;
        case SQUARE:
            printf(" new = old * old\n");
            break;
        default:
            printf("internal error\n");
    }

    /* print the test ... */
    printf("  Test: divisible by %d\n", prog->divisible_test);

    /* ... and the 'then' and 'else' branch of the test */
    printf("    If true: throw to monkey %d\n", prog->target_monkey_true);
    printf("    If false: throw to monkey %d\n", prog->target_monkey_false);

    return;
}

/* executes a monkey program */
void run_monkey_program(monkeyProgram *prog, monkeyState **states, int super_modulo) {
    for (int i = 0; i < get_length_longLongList(states[prog->index]->items); i++, states[prog->index]->no_items_processed++) {
        long long item = get_item_longLongList(states[prog->index]->items, i);
        switch (prog->op) {
            case ADD_CONST:
                item += prog->op_value;
                break;
            case MUL_CONST:
                item *= prog->op_value;
                break;
            case SQUARE:
                item *= item;
                break;
        }
        item %= super_modulo;
        if (item % prog->divisible_test)
            add_elem_longLongList(states[prog->target_monkey_false]->items, item);
        else
            add_elem_longLongList(states[prog->target_monkey_true]->items, item);
    }
    delete_longLongList(states[prog->index]->items);

    return;
}

/* allocates a new monkey execution */
monkeyState *new_monkey_state(longLongList *il) {
    monkeyState *ms = (monkeyState *)malloc(sizeof(monkeyState));
    ms->no_items_processed = 0;
    ms->items = copy_longLongList(il);
    return (ms);
}

/* deletes the monkey state */
void delete_monkey_state(monkeyState *ms) {
    delete_longLongList(ms->items);
    free(ms->items);
    return;
}

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s monkey-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        monkeyProgram *progs[MAX_PROGS];
        monkeyState *states[MAX_PROGS];

        /* read all the programs into memory */
        int no_monkeys = 0;
        int super_modulo = 1;
        for (; (no_monkeys < MAX_PROGS) && (progs[no_monkeys] = read_monkey_program(fp)); no_monkeys++) {
            if (progs[no_monkeys]->index != no_monkeys) {
                printf("Internal monkey indexing error: found %d, expected %d\n",
                       progs[no_monkeys]->index, no_monkeys);
                return (-10);
            }
            super_modulo *= progs[no_monkeys]->divisible_test;
            // print_monkey_program(progs[no_monkeys]);
        }

        /* initialize the monkey states */
        for (int i = 0; i < no_monkeys; i++)
            states[i] = new_monkey_state(progs[i]->starting_items);

        /* execute the program for n rounds */
        for (int round = 0; round < 10000; round++) {
            for (int i = 0; i < no_monkeys; i++)
                run_monkey_program(progs[i], states, super_modulo);

            // printf("\n==After round %d ==\n", round + 1);
            // for (int i = 0; i < no_monkeys; i++)
            //     printf("Monkey %d inspected items %d times.\n", i, states[i]->no_items_processed);
        }

        /* determine the most and second-most active monkey */
        long long top = 0;
        for (int i = 0; i < no_monkeys; i++)
            top = (states[i]->no_items_processed > top) ? states[i]->no_items_processed : top;
        long long top2 = 0;
        for (int i = 0; i < no_monkeys; i++)
            top2 = (states[i]->no_items_processed > top2 && states[i]->no_items_processed < top) ? states[i]->no_items_processed : top2;

        printf("Score (%lld, %lld): %lld\n", top, top2, top * top2);

        /* free memory */
        for (int i = 0; i < no_monkeys; i++) {
            delete_monkey_program(progs[i]);
            delete_monkey_state(states[i]);
            free(progs[i]);
            free(states[i]);
        }
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}