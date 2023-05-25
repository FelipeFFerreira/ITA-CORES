#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <stdbool.h>
#include <sys/types.h>

void GenerateVVP();

void Command(char *, char*, char);

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
  

    //     system("cd ../testbench_tests && iverilog testbench.v");
    //     char cmd[100];
    //     sprintf(cmd, "cd ../testbench_tests && vvp a.out > ../%s/%s.vvp", test[i], test[i]);
    //     system(cmd);
    //     sprintf(cmd, "cd ../testbench_tests && cp testbench.vcd ../%s", test[i]);
    //     system(cmd);

    // }
    GenerateVVP();
    return 0;
}


void Command(char *directory_path, char *test, char cmd) {
    
    const char* directory_path_base = "../../tests/base_testbench/"; 
    char command[100];

    if (cmd == 'v') {
        snprintf(command, sizeof(command), "(cd %s && %s)", directory_path_base, "(iverilog testbench.v)");
    } else if (cmd == 'x') {
        snprintf(command, sizeof(command), "(cd %s && mv testbench_XD.vcd %s%s/)", directory_path_base, directory_path, test);
    } else if (cmd == 'p') {
            snprintf(command, sizeof(command), "(cd %s && %s)", directory_path_base, "vvp a.out");
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
    
    //sprintf(cmd, "cd ../testbench_tests && cp testbench.vcd ../%s", test[i]);
}

void GenerateVVP() {
    FILE * fptr1, * fptr2;
    char linha[2000][2000], path_file_output[80];
    const char* directory_path = "../../build/"; 
    const char* directory_path_base = "../../tests/base_testbench/"; 
    char path_testbench;
    char dir_at[50];
    int count = 0;

    sprintf(dir_at, "%s%sfemtosoc.v", directory_path_base, "file_base/");
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
                sprintf(dir_at, "%s%s", directory_path_base, "femtosoc.v");
                fptr2 = mode_file(dir_at, "w");
                for (int j = 0; j < count; j++) {
                    char arq_hex[100];
                    if (strstr(linha[j], "hex.hex")) {
                        sprintf(arq_hex, "\t$readmemh(\"%s%s/%s_firmware.hex\", RAM);\n", directory_path, entry->d_name, entry->d_name);
                        fprintf(fptr2, arq_hex);  
                    }
                    else {
                        fprintf(fptr2, linha[j]);
                    }
                }
                fclose(fptr2);
                Command("", "", 'v');
                Command("", "", 'p');
                Command(directory_path, entry->d_name, 'x');
                // exit(1);
            }
        }
    }
    closedir(directory);
    
}