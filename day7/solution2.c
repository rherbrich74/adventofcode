/* --- Day 7: No Space Left On Device ---

2022 written by Ralf Herbrich
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#define MAXLEN 256

/* type definition of a single file */
typedef struct file_ {
    char *filename; /* name of the file */
    long size;      /* size of the file */
} file;

/* type definition of a single directory */
typedef struct dir_ {
    char *dirname;         /* name of the directory */
    struct dir_ *parent;   /* pointer to the parent directory */
    int no_files;          /* number of files in the directory */
    struct file_ **files;  /* array of files */
    int no_subdirs;        /* number of subdirectories */
    struct dir_ **subdirs; /* array of subdirectories */
} dir;

/* creates a new file structure from filename and size */
file *new_file(const char *filename, long size) {
    file *f;

    if (!(f = (file *)malloc(sizeof(file)))) {
        printf("Not enough memory\n");
        exit(-1);
    }
    if (!(f->filename = (char *)malloc(strlen(filename) + 1))) {
        printf("Not enough memory\n");
        exit(-1);
    }
    strcpy(f->filename, filename);
    f->size = size;
    return (f);
}

/* deletes the filename structure content */
void delete_file(const file *f) {
    if (f)
        free(f->filename);
    return;
}

/* creates a new directory structure from directory name*/
dir *new_dir(const char *dirname, dir *parent) {
    dir *d;

    if (!(d = (dir *)malloc(sizeof(dir)))) {
        printf("Not enough memory\n");
        exit(-1);
    }
    if (!(d->dirname = (char *)malloc(strlen(dirname) + 1))) {
        printf("Not enough memory\n");
        exit(-1);
    }
    strcpy(d->dirname, dirname);
    d->parent = parent;
    d->files = NULL;
    d->subdirs = NULL;
    d->no_files = 0;
    d->no_subdirs = 0;
    return (d);
}

/* deletes the directory structure */
void delete_dir(const dir *d) {
    if (d) {
        free(d->dirname);

        /* free all files */
        for (int i = 0; i < d->no_files; i++) {
            delete_file(d->files[i]);
            free(d->files[i]);
        }
        if (d->files) free(d->files);

        /* free all subdirectories */
        for (int i = 0; i < d->no_subdirs; i++) {
            delete_dir(d->subdirs[i]);
            free(d->subdirs[i]);
        }
        if (d->subdirs) free(d->subdirs);
    }
    return;
}

/* add a new file to the current directory */
void add_file(dir *d, const char *filename, long sz) {
    if (d) {
        if (d->no_files == 0)
            d->files = (file **)malloc(sizeof(file *));
        else
            d->files = (file **)realloc(d->files, sizeof(file *) * (d->no_files + 1));
        d->files[d->no_files++] = new_file(filename, sz);
    }
    return;
}

/* add a new subdirectory to the current directory */
void add_subdirectory(dir *d, const char *dirname) {
    if (d) {
        if (d->no_subdirs == 0)
            d->subdirs = (dir **)malloc(sizeof(dir *));
        else
            d->subdirs = (dir **)realloc(d->subdirs, sizeof(dir *) * (d->no_subdirs + 1));
        d->subdirs[d->no_subdirs++] = new_dir(dirname, d);
    }
    return;
}

/* finds a subdirectory in a structure (or NULL, if the string does not exist) */
dir *find_dir(dir *d, const char *dirname) {
    if (d) {
        for (int i = 0; i < d->no_subdirs; i++)
            if (!strcmp(d->subdirs[i]->dirname, dirname))
                return (d->subdirs[i]);
    }
    return (NULL);
}

/* returns the total size of the directory d (including sub-directories) */
long total_size(dir *d) {
    if (d) {
        long size = 0L;

        /* add the file sizes */
        for (int i = 0; i < d->no_files; i++)
            size += d->files[i]->size;

        /* add the sub-directory sizes */
        for (int i = 0; i < d->no_subdirs; i++)
            size += total_size(d->subdirs[i]);

        return (size);
    }

    return (0L);
}

/* returns the sub-directory which is closest in size to the necessary size */
void find_closest_match(dir *d, long necessary, long *cur_best) {
    if (d) {
        long size = total_size(d);
        if (size >= necessary && size < *cur_best)
            *cur_best = size;

        /* add the sub-directory sizes */
        for (int i = 0; i < d->no_subdirs; i++) {
            find_closest_match(d->subdirs[i], necessary, cur_best);
        }
        return;
    }
    return;
}

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s dir-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* create root directory entry */
        dir *root = new_dir("/", NULL);
        if (!fgets(buffer, MAXLEN - 1, fp) || strncmp(buffer, "$ cd /", 6)) {
            printf("Could not read first line: '%s'\n", buffer);
            return (-2);
        }

        dir *current = root;
        int buffer_filled = 0;
        /* parsing all commands to reconstruct the directory structure */
        while (buffer_filled || fgets(buffer, MAXLEN - 1, fp)) {
            buffer_filled = 0;
            /* handle 'ls' command */
            if (!strncmp(buffer, "$ ls", 4)) {
                while (fgets(buffer, MAXLEN - 1, fp) && (buffer[0] != '$')) {
                    char s1[MAXLEN];
                    char s2[MAXLEN];
                    if (sscanf(buffer, "%s %s", s1, s2) != 2) {
                        printf("Format error: '%s'\n", buffer);
                        return (-3);
                    }

                    if (!strcmp(s1, "dir")) {
                        add_subdirectory(current, s2);
                    } else {
                        add_file(current, s2, atoi(s1));
                    }
                }
                buffer_filled = 1;
            } else if (!strncmp(buffer, "$ cd ..", 7)) {
                current = current->parent;
            } else if (!strncmp(buffer, "$ cd", 4)) {
                char s1[MAXLEN];
                char s2[MAXLEN];
                if (sscanf(&(buffer[2]), "%s %s", s1, s2) != 2) {
                    printf("Format error: '%s'\n", buffer);
                    return (-3);
                }

                if (!(current = find_dir(current, s2))) {
                    printf("Incorrect directory name: '%s\n", s2);
                    return (-5);
                }
            }
        }

        long space_necessary = 30000000L - (70000000L - total_size(root));
        long smallest_match = LONG_MAX;
        find_closest_match(root, space_necessary, &smallest_match);
        printf("Necessary space:      %ld\nSmallest directory:   %ld\n", space_necessary, smallest_match);

        /* clean up memory */
        delete_dir(root);
        free(root);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}