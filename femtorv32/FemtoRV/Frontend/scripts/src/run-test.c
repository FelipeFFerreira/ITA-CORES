#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#include "common/definitions.h"


static FILE * mode_file(char file[], char mode[]) {
    FILE *fptr;
    if( (fptr = fopen(file, mode)) == NULL) {
        fprintf(stdout, "Error opening file [%s]\n!", file);
        exit(1);
    }
    return fptr;
}

int main()
{
    char linha[20], linha_t[20];
    char * test[N_TEST] = {"add", "addi", "and", "andi", "auipc", "beq", "bge", "bgeu", "blt", "bltu",
                            "bne", "jal", "jalr", "lb", "lbu", "lh", "lhu", "lui","lw", "or", "ori",
                            "sb", "sh", "sll", "slli", "slt", "slti", "sra", "srai", "srl", "srli",
                            "sub", "sw", "xor", "xori"};

    FILE * fptr_file_test, * fptr_file_result, * fptr_file_reference, * fptr_success, * fptr_fail, * fptr_bug;

    fptr_success = mode_file("success.txt", "w");
    fptr_fail = mode_file("fail.txt", "w");
    //fptr_bug = mode_file("bug.txt", "w");

    for (int i = 0; i < N_TEST; i++)
    {
        fprintf(stdout, "%s %s\n", "Checking test result file: ", test[i]);
        char dir_test[20], file_test[20], file_result[20], file_reference[60];
        sprintf(dir_test, "..%s%s%s%", syst, test[i], syst);
        sprintf(file_test, "%s%s.vvp", dir_test, test[i]);
        sprintf(file_reference, "../references/%s.reference_output", test[i]);
        // sprintf(file_result, "%s%s-result.log", dir_test, test[i]);

        fptr_file_test = mode_file(file_test, "r");
        printf("file: %s\n", file_test);
        fptr_file_reference =  mode_file(file_reference, "r");
        // fptr_file_result = mode_file(file_result, "w");
        
        bool fail = false, sucess = false, ok = false;

        while (!feof(fptr_file_reference)) {
            if (fgets(linha, 20, fptr_file_reference)) {
                while (!feof(fptr_file_test)) {
                    if (fgets(linha_t, 20, fptr_file_test)) {
                        if (strncmp(linha, linha_t, 8) == 0) {
                            ok = true;
                            break;
                        }
                    }
                }
                if (!ok) {
                    fprintf(fptr_fail, "Test: [ %s ] Falhou ao buscar a assinatura %s\n", test[i], linha);
                    fail = true;
                    break;
                }
                ok = false;
                fseek(fptr_file_test, 0, SEEK_SET);
            }
        }
        if (!fail) {
            fprintf(fptr_success, "Test: [%s] Encontrou todas as assinaturas\n", test[i]);
        }
    }

    return 0;
}

