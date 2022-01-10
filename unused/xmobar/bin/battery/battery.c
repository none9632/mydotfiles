#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	FILE *capacity_f = fopen("/sys/class/power_supply/BAT1/capacity", "r");
	FILE *status_f = fopen("/sys/class/power_supply/BAT1/status", "r");
	int capacity, number;
	char status;

	if (capacity_f == NULL || status_f == NULL)
		exit(EXIT_FAILURE);

	fscanf(capacity_f, "%i", &capacity);
	fscanf(status_f, "%c", &status);
	number = capacity / 12.5;

	if (status == 'D')
	{
		if (number > 5)
			printf("<icon=battery/off/battery_off_%d.xpm/> <fc=#98be65>%d</fc>%%\n", number, capacity);
		else if (number > 1)
			printf("<icon=battery/off/battery_off_%d.xpm/> <fc=#da8548>%d</fc>%%\n", number, capacity);
		else
			printf("<icon=battery/off/battery_off_%d.xpm/> <fc=#ff6c6b>%d</fc>%%\n", number, capacity);
	}
	else
	{
		printf("<icon=battery/on/battery_on_%d.xpm/> <fc=#98be65>%d</fc>%%\n", number, capacity);
	}

	fclose(capacity_f);
	fclose(status_f);
	return 0;
}
