/* --- Day 11: Monkey in the Middle ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256
#define MAX_PROGS 10

/* defines a new type for list of integer values */
typedef struct intList_ {
    int length;
    int size;
    int *values;
} intList;

/* creates an empty list of integers */
intList *new_intList() {
    intList *il = (intList *)malloc(sizeof(intList));
    il->length = 0;
    il->size = 0;
    il->values = NULL;
    return (il);
}

/* deletes all memory that makes up an integer list */
void delete_intList(intList *il) {
    if (il->values) {
        free(il->values);
        il->values = NULL;
    }
    il->size = 0;
    il->length = 0;
    return;
}

/* prints an integer list on the screen */
void print_intList(intList *il) {
    for (int i = 0; i < il->length; i++) {
        printf("%d", il->values[i]);
        if (i < il->length - 1)
            printf(",");
    }

    return;
}

/* returns the length of the integer list */
int get_length_intList(intList *il) {
    return (il->length);
}

/* returns the ith item from an integer list */
int get_item_intList(intList *il, int idx) {
    if (idx >= il->length) {
        printf("Incorrect index access: %d", idx);
        print_intList(il);
        printf("\n");
        exit(-1);
    }
    return (il->values[idx]);
}

/* adds an element to the end of the list */
void add_elem_intList(intList *il, int i) {
    /* re-allocate memory for the additional element, if necessary */
    if (il->length == il->size) {
        if (il->size > 0) {
            il->values = (int *)realloc(il->values, sizeof(int) * (il->size * 2));
            il->size *= 2;
        } else {
            il->values = (int *)malloc(sizeof(int));
            il->size = 1;
        }
    }

    il->values[il->length++] = i;
    return;
}

/* removes the last element from a list */
void remove_last_elem_intList(intList *il) {
    /* re-allocate memory for the additional element */
    if (il->length > 0)
        il->length--;

    return;
}

/* makes a deep copy of an integer list */
intList *copy_intList(intList *src) {
    intList *dest = new_intList();
    for(int i = 0; i < src->length; i++) {
        add_elem_intList(dest, get_item_intList(src, i));
    }

    return(dest);
}

/* defines the three types of monkey operation */
typedef enum monkeyOp_ { ADD_CONST,
                         MUL_CONST,
                         SQUARE } monkeyOp;

/* defines a new monkey program */
typedef struct monkeyProgram_ {
    int index;               /* the index of the monkey */
    intList *starting_items; /* the starting items */
    monkeyOp op;             /* operation in each cycle */
    int op_value;            /* additional const value of the monkey operation */
    int divisible_test;      /* the number that the worry level needs to be divisible by */
    int target_monkey_true;  /* monkey that receives the items when the test is true */
    int target_monkey_false; /* monkey that receives the items when the test is false */
} monkeyProgram;

/* defines a monkey state */
typedef struct monkeyState_ {
    int no_items_processed; /* number of items processed */
    intList *items; /* current list of items to be processed by monkey */
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
    prog->starting_items = new_intList();
    if (fscanf(fp, "  Starting items: ") != 0) {
        printf("Expecting at least one starting item\n");
        exit(-3);
    }
    do {
        fscanf(fp, "%d%c", &i, &c);
        add_elem_intList(prog->starting_items, i);
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
        delete_intList(prog->starting_items);
        free(prog->starting_items);
    }

    return;
}

/* prints a monkey program on the screen */
void print_monkey_program(monkeyProgram *prog) {
    printf("Monkey %d:\n", prog->index);

    /* print starting items */
    printf("  Starting items: ");
    print_intList(prog->starting_items);
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
void run_monkey_program(monkeyProgram *prog, monkeyState **states) {
    for(int i = 0; i < get_length_intList(states[prog->index]->items); i++, states[prog->index]->no_items_processed++) {
        int item = get_item_intList(states[prog->index]->items, i);
        switch(prog->op) {
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
        item /= 3;
        if(item % prog->divisible_test) 
            add_elem_intList(states[prog->target_monkey_false]->items, item);
        else
            add_elem_intList(states[prog->target_monkey_true]->items, item);
    }
    delete_intList(states[prog->index]->items);

    return;
}

/* allocates a new monkey execution */
monkeyState *new_monkey_state(intList *il) {
    monkeyState *ms = (monkeyState *) malloc (sizeof (monkeyState));
    ms->no_items_processed = 0;
    ms->items = copy_intList(il);
    return (ms);
}

/* deletes the monkey state */
void delete_monkey_state(monkeyState *ms) {
    delete_intList(ms->items);
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
        for (; (no_monkeys < MAX_PROGS) && (progs[no_monkeys] = read_monkey_program(fp)); no_monkeys++) {
            if (progs[no_monkeys]->index != no_monkeys) {
                printf("Internal monkey indexing error: found %d, expected %d\n",
                       progs[no_monkeys]->index, no_monkeys);
                return (-10);
            }
            // print_monkey_program(progs[no_monkeys]);
        }

        /* initialize the monkey states */
        for (int i = 0; i < no_monkeys; i++)
            states[i] = new_monkey_state(progs[i]->starting_items);

        /* execute the program for n rounds */
        for(int round = 0; round < 20; round++) {
            for (int i = 0; i < no_monkeys; i++)
                run_monkey_program(progs[i], states);

            // printf("\nAfter round %d, the monkeys are holding items with these worry levels:\n", round+1);
            // for (int i = 0; i < no_monkeys; i++) {
            //     printf("Monkey %d [%d]: ", i, states[i]->no_items_processed);
            //     print_intList(states[i]->items);
            //     printf("\n");
            // }
        }

        /* determine the most and second-most active monkey */
        int top = 0;
        for(int i = 0; i < no_monkeys; i++) 
            top = (states[i]->no_items_processed > top)?states[i]->no_items_processed:top;
        int top2 = 0;
        for(int i = 0; i < no_monkeys; i++) 
            top2 = (states[i]->no_items_processed > top2 && states[i]->no_items_processed < top)?states[i]->no_items_processed:top2;
            
        printf("Score (%d, %d): %d\n", top, top2, top * top2);

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