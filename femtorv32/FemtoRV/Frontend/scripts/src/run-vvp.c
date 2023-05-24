#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <stdbool.h>
#include <sys/types.h>

void GenerateVVP();

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

void GenerateVVP() {
    FILE * fptr1, * fptr2;
    char linha[2000][2000], path_file_output[80];
    const char* path_testbench = "../../../RTL/testbench.v";
    const char* directory_path = "../../build/"; 
    int count = 0;

    fptr1 = mode_file(path_testbench, "r");
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
                sprintf(path_file_output, "%s%s/%s_testbench.v", directory_path, entry->d_name, entry->d_name);
                fptr2 = mode_file(path_file_output, "w");
                for (int j = 0; j < count; j++) {
                    if (strstr(linha[j], "hex.hex"))  {
                        char arq_hex[100];
                        sprintf(arq_hex, "$readmemh(\"%s_firmware.hex\", MEM);\n", entry->d_name);
                        fprintf(fptr2, "%s", arq_hex);
                    }
                    else {
                        fprintf(fptr2, linha[j]);
                    }
                }
                fclose(fptr2);
            }
        }
    }
    closedir(directory);
}