#include <stdio.h>
#include <stdlib.h>

#define SIZE 28

#define mem_available_s buffers_s
#define swap_cached_s   shmem_s
#define active_s        shmem_s
#define inactive_s      shmem_s
#define active_anon_s   shmem_s
#define inactive_anoa_s shmem_s
#define active_file_s   shmem_s
#define inactive_file_s shmem_s
#define unevictable_s   shmem_s
#define mlocked_s       shmem_s
#define swap_total_s    shmem_s
#define swap_free_s     shmem_s
#define dirty_s         shmem_s
#define writeback_s     shmem_s
#define anon_pages_s    shmem_s
#define mapped_s        shmem_s
#define kreclaimable_s  sreclaimable_s
#define slab_s          sreclaimable_s

int take_num(char *str)
{
  int num = 0;

  for (int i = 16; i < SIZE - 4; ++i)
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

  fread(mem_total_s,     sizeof(char), SIZE, meminfo);
  fread(mem_free_s,      sizeof(char), SIZE, meminfo);
  fread(buffers_s,       sizeof(char), SIZE, meminfo);
  fread(mem_available_s, sizeof(char), SIZE, meminfo);
  fread(cached_s,        sizeof(char), SIZE, meminfo);
  fread(swap_cached_s,   sizeof(char), SIZE, meminfo);
  fread(active_s,        sizeof(char), SIZE, meminfo);
  fread(inactive_s,      sizeof(char), SIZE, meminfo);
  fread(active_anon_s,   sizeof(char), SIZE, meminfo);
  fread(inactive_anoa_s, sizeof(char), SIZE, meminfo);
  fread(active_file_s,   sizeof(char), SIZE, meminfo);
  fread(inactive_file_s, sizeof(char), SIZE, meminfo);
  fread(unevictable_s,   sizeof(char), SIZE, meminfo);
  fread(mlocked_s,       sizeof(char), SIZE, meminfo);
  fread(swap_total_s,    sizeof(char), SIZE, meminfo);
  fread(swap_free_s,     sizeof(char), SIZE, meminfo);
  fread(dirty_s,         sizeof(char), SIZE, meminfo);
  fread(writeback_s,     sizeof(char), SIZE, meminfo);
  fread(anon_pages_s,    sizeof(char), SIZE, meminfo);
  fread(mapped_s,        sizeof(char), SIZE, meminfo);
  fread(shmem_s,         sizeof(char), SIZE, meminfo);
  fread(kreclaimable_s,  sizeof(char), SIZE, meminfo);
  fread(slab_s,          sizeof(char), SIZE, meminfo);
  fread(sreclaimable_s,  sizeof(char), SIZE, meminfo);

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
    if (used_M < 1000)
      printf(" %iM/%.2lfG \n", (int)used_M, total_M / 1024);
    else
      printf("%iM/%.2lfG \n", (int)used_M, total_M / 1024);
  else
    printf("%.2lfG/%.2lfG \n", used_M / 1024, total_M / 1024);

  fclose(meminfo);
  return 0;
}
