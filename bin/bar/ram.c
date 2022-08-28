#include <stdio.h>
#include <stdlib.h>
#include <regex.h>
#include <string.h>

#define SIZE 64

char* regex_search(FILE *file, char *regexp, char *line)
{
  regex_t re;

  if (regcomp(&re, regexp, REG_EXTENDED) != 0)
    exit(EXIT_FAILURE);

  while ((fgets(line, 64, file)) != NULL)
    {
      line[strlen(line)-1] = '\0';
      if (regexec(&re, line, 0, NULL, 0) == 0)
        return line;
    }
}

int take_num(char *str)
{
  int num = 0;

  for (int i = 16; i < strlen(str) - 3; ++i)
    {
      char ch = str[i];
      if (ch == ' ')
        continue;
      num = num * 10 + (ch - '0');
    }

  return num;
}

int main(void)
{
  FILE *meminfo = fopen("/proc/meminfo", "r");
  char mem_total_s[SIZE],
    mem_free_s[SIZE],
    buffers_s[SIZE],
    cached_s[SIZE],
    shmem_s[SIZE],
    sreclaimable_s[SIZE];

  if (meminfo == NULL)
    exit(EXIT_FAILURE);

  regex_search(meminfo, "MemTotal:",     mem_total_s);
  regex_search(meminfo, "MemFree:",      mem_free_s);
  regex_search(meminfo, "Buffers:",      buffers_s);
  regex_search(meminfo, "Cached:",       cached_s);
  regex_search(meminfo, "Shmem:",        shmem_s);
  regex_search(meminfo, "SReclaimable:", sreclaimable_s);

  int mem_total    = take_num(mem_total_s),
      mem_free     = take_num(mem_free_s),
      buffers      = take_num(buffers_s),
      shmem        = take_num(shmem_s),
      sreclaimable = take_num(sreclaimable_s),
      cached       = take_num(cached_s) + sreclaimable - shmem;

  int used = mem_total - (mem_free + buffers + cached);
  double total_M = mem_total / 1024;
  double used_M = used / 1024;

  if (used_M < 1024)
    printf("%iM/%.2lfG", (int)used_M, total_M / 1024);
  else
    printf("%.2lfG/%.2lfG", used_M / 1024, total_M / 1024);

  fclose(meminfo);
  return 0;
}
