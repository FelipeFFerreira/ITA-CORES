#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <stdbool.h>
#include <sys/types.h>
#include <time.h>
#include <string.h>
#include <unistd.h>


void GenerateVVP(char *);

void Command(char *, char*, char, char *);

void ResultTest(char *, char *);

static FILE * mode_file(char file[], char mode[]) {
    FILE *fptr;
    if( (fptr = fopen(file, mode)) == NULL) {
        puts("Error opening file!");
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
   
    printf("comando : %s\n", command);
    int status = system(command);

    if (status != -1) {
        wait(&status);

        if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
            printf("Arquivo VCD com sucesso!\n");
        } else {
            printf("Erro ao Gerar arquivo VCD\n");
        }
    } else {
        printf("Erro ao executar o comando 'make programa'.\n");
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
        printf(">> Genarete Test [%s]\n", string);
    
  
    
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
        perror("Erro ao abrir o diretório");
        return 1;
    }

    struct dirent* entry;

    while ((entry = readdir(directory)) != NULL) {
        if (entry->d_type == DT_DIR) {
            
            if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
                fprintf(stdout, "[%s] Gerando arquivos para simulação [%s]\n",  __func__, entry->d_name);
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
    FILE *fptr1, *fptr2;
    char *directory_path_base[200];
    bool pass = true;

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
    fptr2 = mode_file("../../build/resultado_tests.log", "a");
    if (pass)
        fprintf(fptr2, "%s: TESTE [%s]\t\t\t\t ------- [PASSOU]\n", time_str, test);
    else 
        fprintf(fptr2, "%s: TESTE [%s]\t\t\t\t ------- [FALHOU]\n", time_str, test);

    fclose(fptr1);
    fclose(fptr2);
}