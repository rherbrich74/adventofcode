/* --- Day 15: Beacon Exclusion Zone ---

2022 written by Ralf Herbrich
*/

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 1024

/* defines the type of a linked sensor/beacon list entry */
typedef struct sensorBeacon_ {
    int sensor_x;               /* x coordinate of the sensor */
    int sensor_y;               /* y coordinate of the sensor */
    int beacon_x;               /* x coordinate of the beacon */
    int beacon_y;               /* y coordinate of the beacon */
    int distance;               /* Manhattan distance between beacon and sensor */
    struct sensorBeacon_ *next; /* pointer to the next sensor/beacon pair */
} sensorBeacon;

/* defines the type of a linked interval list entry */
typedef struct interval_ {
    int start;              /* start value of the interval (inclusive) */
    int end;                /* end value of the interval (inclusive) */
    struct interval_ *next; /* pointer to the next interval */
} interval;

/* read the map from a stream */
sensorBeacon *read_sensorBeacon_list(FILE *fp) {
    char buffer[MAXLEN];
    sensorBeacon *head = NULL;
    sensorBeacon *tail = NULL;
    int s_x, s_y, b_x, b_y;

    /* read line by line */
    while (fscanf(fp, "Sensor at x=%d, y=%d: closest beacon is at x=%d, y=%d\n", &s_x, &s_y, &b_x, &b_y) == 4) {
        /* fill a new element with the data read */
        sensorBeacon *sb = (sensorBeacon *)malloc(sizeof(sensorBeacon));
        sb->sensor_x = s_x;
        sb->sensor_y = s_y;
        sb->beacon_x = b_x;
        sb->beacon_y = b_y;
        sb->distance = abs(s_x - b_x) + abs(s_y - b_y);
        sb->next = NULL;

        /* connect the new entry to the list (either make it head & tail or add it to the tail element) */
        if (!head)
            head = tail = sb;
        else {
            tail->next = sb;
            tail = sb;
        }
    }

    /* return the map read from the stream */
    return (head);
}

/* prints the list of sensor/beacon information */
void print_sensorBeacon_list(sensorBeacon *head) {
    while (head) {
        printf("Sensor at x=%d, y=%d: closest beacon is at x=%d, y=%d (distance %d)\n",
               head->sensor_x, head->sensor_y, head->beacon_x, head->beacon_y, head->distance);
        head = head->next;
    }
    return;
}

/* free the memory of the sensor/beacon list */
void delete_sensorBeacon_list(sensorBeacon *head) {
    while (head) {
        sensorBeacon *tmp = head->next;
        free(head);
        head = tmp;
    }
    return;
}

/* adds a new interval to an interval list (and returns the head) */
interval *add_interval(interval *head, int start, int end) {
    /* if the list is empty, create the head of the list */
    if (!head) {
        head = (interval *)malloc(sizeof(interval));
        head->start = start;
        head->end = end;
        head->next = NULL;
        return (head);
    }

    /* otherwise, move to the tail and add a new element */
    interval *tail = head;
    while (tail->next) tail = tail->next;
    tail->next = (interval *)malloc(sizeof(interval));
    tail->next->start = start;
    tail->next->end = end;
    tail->next->next = NULL;

    return (head);
}

/* checks, if a point is contained in any of the intervals */
int intervals_contain_point(interval *head, int x) {
    while (head) {
        if (x >= head->start && x <= head->end)
            return (1);
        head = head->next;
    }

    return (0);
}

/* free the memory of the interval list */
void delete_interval_list(interval *head) {
    while (head) {
        interval *tmp = head->next;
        free(head);
        head = tmp;
    }
    return;
}

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    int target_row = 2000000;

    /* argument check */
    if (argc < 2) {
        printf("Usage: %s sensor-file [N]\n", argv[0]);
        return (-1);
    }

    /* check for the third argument */
    if (argc == 3)
        target_row = atoi(argv[2]);

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the sensor-beacon list from the stream */
        sensorBeacon *sensors = read_sensorBeacon_list(fp);

        /* build the list of intervals that cannot contain a beacon (and total interval boundaries) */
        interval *intervals = NULL;
        int min_x = INT_MAX;
        int max_x = INT_MIN;
        for (sensorBeacon *it = sensors; it; it = it->next) {
            int d = it->distance - abs(it->sensor_y - target_row);
            if (d >= 0) {
                int start = it->sensor_x - (it->distance - abs(it->sensor_y - target_row));
                int end = it->sensor_x + (it->distance - abs(it->sensor_y - target_row));

                /* remove the actual beacon (!) */
                start = (it->beacon_x == start) ? start + 1 : start;
                end = (it->beacon_x == end) ? end - 1 : end;

                /* update min and max */
                min_x = (start < min_x) ? start : min_x;
                max_x = (end > max_x) ? end : max_x;

                /* add the interval */
                intervals = add_interval(intervals, start, end);
            }
        }

        /* now check every point between min_x and max_x to be contained in an interval */
        int score = 0;
        for(int x = min_x; x <= max_x; x++) {
            if (intervals_contain_point(intervals, x))
                score++;
        }
        printf("Score: %d\n", score);

        /* free the memory for the sensor-beacon list */
        delete_sensorBeacon_list(sensors);
        /* free the memory for the interval list */
        delete_interval_list(intervals);
    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}