#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

void read_stat(long long int *a)
{
    FILE *stat = fopen("/proc/stat","r");

    if (stat == NULL)
        exit(EXIT_FAILURE);

    fscanf(stat,"%*s %lli %lli %lli %lli %lli %lli %lli", &a[0], &a[1], &a[2], &a[3], &a[4], &a[5], &a[6]);
    fclose(stat);
}

int main(void)
{
    long long int a[7], b[7];
    double delta;
    int used;

    read_stat(a);
    usleep(250000);
    read_stat(b);

    delta = ((b[0] + b[1] + b[2] + b[3] + b[4] + b[5] + b[6]) - (a[0] + a[1] + a[2] + a[3] + a[4] + a[5] + a[6]));
    used  = (delta - (b[3] - a[3])) / delta * 100;

    printf("%i%%", used);

    return 0;
}
