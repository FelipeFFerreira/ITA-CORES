#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>

#include "common/definitions.h"


static FILE * mode_file(char file[], char mode[]) {
    FILE *fptr;
    if( (fptr = fopen(file, mode)) == NULL) {
        puts("Error opening file!");
        exit(1);
    }
    return fptr;
}

int main()
{
    char ch1[100], ch2[100], ch3[100];
    char * test[N_TEST] = {"add", "addi", "and", "andi", "auipc", "beq", "bge", "bgeu", "blt", "bltu",
                            "bne", "jal", "jalr", "lb", "lbu", "lh", "lhu", "lui","lw", "or", "ori",
                            "sb", "sh", "sll", "slli", "slt", "slti", "sra", "srai", "srl", "srli",
                            "sub", "sw", "xor", "xori"};

    int count = 0;
    FILE * fptr1, * fptr2;

    for (int i = 0; i < N_TEST; i++)
    {
        fprintf(stdout, "%d. %s %s\n", i + 1, "Generating dump file: ", test[i]);
        char dir_test[20], file_test[20], file_result[20];
        sprintf(dir_test, "..%s%s%s%", syst, test[i], syst);
     
        char cmd[100];

        sprintf(cmd, "cd %s && make %s", dir_test, "clean");
        system(cmd);

        sprintf(cmd, "cd %s && make %s.o", dir_test, test[i]);
        system(cmd);

        sprintf(cmd, "cd %s && make %s > %s.dump ", dir_test, "dump", test[i]);
        system(cmd);
    }

    return 0;
}

