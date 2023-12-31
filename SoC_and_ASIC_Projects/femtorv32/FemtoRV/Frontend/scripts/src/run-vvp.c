#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <stdbool.h>
#include <sys/types.h>
#include <time.h>
#include <string.h>
#include <unistd.h>
#include "definitions.h"


void GenerateVVP(char *);

void Command(char *, char*, char, char *);

void ResultTest(char *, char *);

static FILE * mode_file(char file[], char mode[]) {
    FILE *fptr;
    if( (fptr = fopen(file, mode)) == NULL) {
        printf("Error opening file [%s]\n!", file);
        exit(1);
    }
    return fptr;
}

int main(int argc, char *argv[])
{
    if (argc > 1) {
        char *string = argv[1];
        GenerateVVP(string);
    } else 
        exit(10);

    return 0;
}

void Command(char *directory_path, char *test, char cmd, char *string) {
    
    char* directory_path_base[200];
    snprintf(directory_path_base, sizeof(directory_path_base), "../../%s/base_testbench/", string);

    char command[100];

    if (cmd == 'v') {
        snprintf(command, sizeof(command), "(cd %s && %s)", directory_path_base, "(iverilog testbench.v)");
    } else if (cmd == 'x') {
        snprintf(command, sizeof(command), "(cd %s && mv testbench_XD.vcd %s%s/)", directory_path_base, directory_path, test);
    } else if (cmd == 'p') {
            snprintf(command, sizeof(command), "(cd %s && %s)", directory_path_base, "vvp a.out > output_vvp");
    } else {
    }
   
    printf("\033[1;34mcommand: %s\033[0m\n", command);
    int status = system(command);

    if (status != -1) {
        wait(&status);

        if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
            printf("\033[1;32mVCD file generated successfully!\033[0m\n");
        } else {
            printf("\033[1;31mError generating VCD file.\033[0m\n");
        }
    } else {
        printf("\033[1;31mError executing the 'make programa' command.\033[0m\n");
    }
}

void GenerateVVP(char * string) {
    FILE * fptr1, * fptr2;
    char linha[2000][2000], path_file_output[80];
    char* directory_path = "../../build/"; 
    char* directory_path_base[200];
    char path_testbench;
    char dir_at[50];
    int count = 0;

    // if (strstr(string, "riscv-tests"))
    
    snprintf(directory_path_base, sizeof(directory_path_base), "../../%s/base_testbench/", string);
    printf("\033[1;34m>> Generate Test\033[0m \033[1;35m[%s]\033[0m\n", string);
    
    sprintf(dir_at, "%s%stestbench.v", directory_path_base, "file_base/");
    fptr1 = mode_file(dir_at, "r");
    while (!feof(fptr1)) {
        if (fgets(linha[count], 1000, fptr1)) {
            // fprintf(stdout, "%s", linha[count]);
        }
        count += 1;
    }
    fclose(fptr1);

    DIR* directory = opendir(directory_path);
    if (directory == NULL) {
        perror("Error opening the directory");
        return 1;
    }

    struct dirent* entry;
    while ((entry = readdir(directory)) != NULL) {
        if (entry->d_type == DT_DIR) {
            if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
                fprintf(stdout, "\033[1;34m[%s] Generating simulation files for\033[0m \033[1;35m[%s]\033[0m\n", __func__, entry->d_name);
                sprintf(dir_at, "%s%s", directory_path_base, "testbench.v");
                fptr2 = mode_file(dir_at, "w");
                for (int j = 0; j < count; j++) {
                    char arq_hex[100];
                    if (strstr(linha[j], "hex.hex")) {
                        sprintf(arq_hex, "\t$readmemh(\"%s%s/%s_firmware.hex\", MEM);\n", directory_path, entry->d_name, entry->d_name);
                        fputs(arq_hex, fptr2);  
                    }
                    else {
                        fputs(linha[j], fptr2);
                    }
                }
                fclose(fptr2);
                Command("", "", 'v', string);
                Command("", "", 'p', string);
                Command(directory_path, entry->d_name, 'x', string);
                ResultTest(entry->d_name, string);
            }
        }
    }
    closedir(directory);
}

void ResultTest(char * test, char *string) {

    time_t current_time;
    time(&current_time);
    struct tm* time_info = localtime(&current_time);
    char time_str[20];
    strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", time_info);
    char *directory_path_base[200];
    bool pass = true;
    FILE *fptr_log = mode_file("../../build/resultado_tests.log", "a");
    if (strstr(string, REPO_COMPLIANCE_RISCV_ORG)) {
        FILE *fptr1;
        snprintf(directory_path_base, sizeof(directory_path_base), "../../%s/base_testbench/output_test", string);
        fptr1 = mode_file(directory_path_base, "r");
        char line[100];
        while (!feof(fptr1)) {
            if (fgets(line, sizeof(line), fptr1) != NULL) {
                if (strstr(line, "ERROR") != NULL) { 
                    pass = false;  
                    break;  
                }
            }
        }
        fclose(fptr1);
    }

    if (strstr(string, REPO_RISCV_SUITE_LOWRISCV)) {
        FILE *fptr1, *fptr2, *fptr3;
        char path_test[200], output_reference[200];
        char line_output[100][100], line_reference[100][100];
        int count_output = 0, count_reference = 0;
        snprintf(directory_path_base, sizeof(directory_path_base), "../../%s/base_testbench/memory_contents", string);
        fptr1 = mode_file(directory_path_base, "r");
        snprintf(path_test, sizeof(path_test), "../../%s/references/%s.reference_output", string, test);
        fptr2 = mode_file(path_test, "r");
        snprintf(output_reference, sizeof(output_reference), "../../build/%s/%s_%s.reference_output", test, test, string);
        fptr3 = mode_file(output_reference, "w");
        while (!feof(fptr1)) {
            if (fgets(line_output[count_output], sizeof(line_output[0]), fptr1)) {
                if (strstr(line_output[count_output], "xxxxxxxx") == NULL) {
                    fputs(line_output[count_output], fptr3);
                    if (fgets(line_reference[count_reference], sizeof(line_reference[0]), fptr2)) {
                        line_output[count_output][strcspn(line_output[count_output], "\r\n")] = 0;
                        line_reference[count_reference][strcspn(line_reference[count_reference], "\r\n")] = 0;
                        if (strcmp(line_reference[count_reference], line_output[count_output]) != 0) {
                            printf("\033[1;35m[%s]\033[0m \033[1;33m!=\033[0m \033[1;35m[%s]\033[0m\n", line_output[count_output], line_reference[count_reference]);
                            pass = false;
                        } else {
                            printf("\033[1;35m[%s]\033[0m \033[1;32m==\033[0m \033[1;35m[%s]\033[0m\n", line_output[count_output], line_reference[count_reference]);
                        }
                        count_reference += 1;
                    }
                }
                count_output += 1;
            }
        }
    }

    if (pass)
        fprintf(fptr_log, "%s: TEST [ %-5s]\t------- [PASSED]\n", time_str, test);
    else 
        fprintf(fptr_log, "%s: TEST [ %-5s]\t------- [FAILED]\n", time_str, test);
}