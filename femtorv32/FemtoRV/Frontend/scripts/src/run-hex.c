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

    char dump[1000][500];
    int len_dump = 0;


      for (int i = 0; i < N_TEST; i++) {
        fprintf(stdout, "%d. %s %s\n", i + 1, "Generating hex files: ", test[i]);
        char dir_test[30], file_test[30], file_result[30];
        sprintf(dir_test, "..%s%s%s%", syst, test[i], syst);
        sprintf(file_test, "%s%s.dump", dir_test, test[i]);
        sprintf(file_result, "%s%s.hex", dir_test, test[i]);

        fptr1 = mode_file(file_test, "r");
        fptr2 = mode_file(file_result, "w");

        while (!feof(fptr1)) {
            if (fgets(dump[len_dump], 200, fptr1)) {
                for (int i = 0; i < strlen(dump[len_dump]); i++){
                    if (dump[len_dump][i - 1] == 58 && dump[len_dump][i] == 9) {
                        char instruction[10];
                        for (int j = 0; j < 8; j++) {
                            instruction[j] = dump[len_dump][j + i + 1] == 32 ? '0' : dump[len_dump][j + i + 1];
                        }
                        instruction[8] = '\0';
                        fprintf(fptr2, "%s\n", instruction);
                        break;
                    }
                }
                len_dump += 1;
            }
        }

        len_dump = 0;
        fclose(fptr1);
        fclose(fptr2);
      }
}

