TARGET := cpu

CC     := gcc
CCFLAG := -Wall -O3
FILES  := cpu.c

.PHONY: rebuild clean

$(TARGET): $(FILES)
	$(CC) $(CCFLAG) $(FILES) -o $(TARGET)

rebuild: clean $(TARGET)

clean:
	rm $(TARGET)
