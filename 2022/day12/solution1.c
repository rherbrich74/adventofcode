/* --- Day 12: Hill Climbing Algorithm ---

2022 written by Ralf Herbrich
*/

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLEN 256
#define MAX_WIDTH 200
#define MAX_HEIGHT 100

/* main entry point of the program */
int main(int argc, char *argv[]) {
    FILE *fp;
    char buffer[MAXLEN];
    char map[MAX_HEIGHT][MAX_WIDTH];

    /* argument check */
    if (argc != 2) {
        printf("Usage: %s map-file\n", argv[0]);
        return (-1);
    }

    if ((fp = fopen(argv[1], "r")) != NULL) {
        /* read the map line-by-line */
        int n; /* number of rows of the map */
        int m; /* number of columns of the map */
        int x_start, y_start, x_end, y_end; /* store the coordinates of the start or finish */
        for (n = 0; fgets(buffer, MAXLEN - 1, fp); n++) {
            for (m = 0; (buffer[m] >= 'a' && buffer[m] <= 'z') || (buffer[m] == 'E') || (buffer[m] == 'S'); m++) {
                map[n][m] = buffer[m];
                if (buffer[m] == 'S') {
                    x_start = m;
                    y_start = n;
                    map[n][m] = 'a';
                }
                if (buffer[m] == 'E') {
                    x_end = m;
                    y_end = n;
                    map[n][m] = 'z';
                }
            }
        }

        int N = n * m; /* number of nodes in the graph */

        /* allocate memory for Dijkstra’s algorithm */
        int **cost = (int **)malloc(sizeof(int *) * N);
        for (int i = 0; i < N; i++)
            cost[i] = (int *)malloc(sizeof(int) * N);
        int *distance = (int *)malloc(sizeof(int) * N);
        char *visited = (char *)malloc(sizeof(char) * N);

        /* initialize the distance map */
        for (int from = 0; from < N; from++)
            for (int to = 0; to < N; to++)
                if (from == to) {
                    cost[from][to] = 0;
                } else {
                    int x_from = from % m, y_from = from / m;
                    int x_to = to % m, y_to = to / m;
                    cost[from][to] = N; /* this is larger than the maximum distance on an nxm map */
                    if ((abs(x_from - x_to) == 1 && y_from == y_to) || (abs(y_from - y_to) == 1 && x_from == x_to))
                        if (map[y_to][x_to] - map[y_from][x_from] <= 1) 
                            cost[from][to] = 1;
                }

        /* initialize the shortest-distance vector and visited vector */
        for (int i = 0; i < N; i++) {
            distance[i] = cost[y_start * m + x_start][i];
            visited[i] = 0;
        }
        distance[y_start * m + x_start] = 0;
        visited[y_start * m + x_start] = 1;

        for (int k = 0; k < N; k++) {
            /* determine the next not-visited node to consider */
            int min_distance = N;
            int next_node;
            for (int j = 0; j < N; j++)
                if (!visited[j] && distance[j] < min_distance) {
                    min_distance = distance[j];
                    next_node = j;
                }

            // check if a better path exists through next_node
            visited[next_node] = 1;
            for (int j = 0; j < N; j++)
                if (!visited[j] && min_distance + cost[next_node][j] < distance[j]) {
                    distance[j] = min_distance + cost[next_node][j];
                }
        }

        /* extract the length of the shortest path from both start to finish */
        printf("Shortest path: %d\n", distance[y_end * m + x_end]);

        /* free memory */
        for (int i = 0; i < N; i++)
            free(cost[i]);
        free(cost);
        free(distance);
        free(visited);

    } else {
        printf("Problems opening file %s\n", argv[1]);
    }

    return (0);
}