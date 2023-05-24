#include <stdio.h>
#include <string.h>
#include <stdbool.h>

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
    char * test[N_TEST] = {"add", "addi", "and", "andi", "auipc", "beq", "bge", "bgeu", "blt", "bltu",
                            "bne", "jal", "jalr", "lb", "lbu", "lh", "lhu", "lui","lw", "or", "ori",
                            "sb", "sh", "sll", "slli", "slt", "slti", "sra", "srai", "srl", "srli",
                            "sub", "sw", "xor", "xori"};

    FILE * fptr1, * fptr2;
    char linha[5000][650];
    int count = 0;
    char dir_test[20], file_test[100], file_base[50];

    sprintf(file_base, "%s", "../testbench_tests/file_base/femtosoc.v");
    fptr2 = mode_file(file_base, "r");
    while (!feof(fptr2)) {
        if (fgets(linha[count], 1000, fptr2)) {
            //fprintf(stdout, "%s", linha[count]);
        }
        count += 1;
    }

    fclose(fptr2);

    for (int i = 0; i < N_TEST; i++)
    {
        fprintf(stdout, "%d. %s %s\n", i + 1, "Generating files for compilation:", test[i]);
        char dir_dest[50];
        sprintf(dir_dest, "%s", "../testbench_tests/femtosoc.v");
        fptr2 = mode_file(dir_dest, "w");
        for (int j = 0; j < count; j++) {
            if (strstr(linha[j], "hex.hex"))  {
                char arq_hex[100];
                sprintf(arq_hex, "$readmemh(\"../%s/%s.hex\",RAM);\n", test[i], test[i]);
                fprintf(fptr2, "%s", arq_hex);
            }
            else {
                fprintf(fptr2, linha[j]);
            }
        }
        fclose(fptr2);

        system("cd ../testbench_tests && iverilog testbench.v");
        char cmd[100];
        sprintf(cmd, "cd ../testbench_tests && vvp a.out > ../%s/%s.vvp", test[i], test[i]);
        system(cmd);
        sprintf(cmd, "cd ../testbench_tests && cp testbench.vcd ../%s", test[i]);
        system(cmd);

    }

    return 0;
}

