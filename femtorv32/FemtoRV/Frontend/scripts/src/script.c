#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <stdbool.h>
#include <sys/types.h>
#include <string.h>

void Command(char *, char *, bool);

void MachineCodeTool();

void GeneratSimulation();


int main() {

    char* scriptfilePath_tooltchain = "../../";
    char* scriptfilePath_scripts = "../";

    // Automating TOOLCHAIN-RISC-V
    fprintf(stdout, "[%s] Processando arquivos para compilação\n", __func__);

    Command(scriptfilePath_tooltchain, "make clean", true);

    Command(scriptfilePath_tooltchain, "make riscv-formal", true);
    
    Command(scriptfilePath_tooltchain, "make hex", true);

    // Automating Tools
    fprintf(stdout, "[%s] Compilando ferramentas\n", __func__);

    Command(scriptfilePath_scripts, "make run-tools-elf", true);

    Command(scriptfilePath_scripts, "make run-vvp", true);

    fprintf(stdout, "[%s] Preparando arquivos para formatação\n", __func__);

    MachineCodeTool();

    GeneratSimulation();

    fprintf(stdout, "[%s] Gerando arquivos binarios de cada teste\n", __func__);

    Command(scriptfilePath_tooltchain, "make bin", true);

    return 0;
}

void Command(char * scriptfilePath, char * Command, bool make)
{
    char command[100];

    if (make) {
        snprintf(command, sizeof(command), "(cd %s && %s)", scriptfilePath, Command);
    } else {
        snprintf(command, sizeof(command), "(%s)",  Command);
    }

    int status = system(command);

    if (status != -1) {
        wait(&status);

        if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
            printf("Makefile concluído com sucesso!\n");
        } else {
            printf("Erro na execução do Makefile.\n");
        }
    } else {
        printf("Erro ao executar o comando 'make programa'.\n");
    }
}

void MachineCodeTool() {
    const char* directory_path = "../../build/"; 

    DIR* directory = opendir(directory_path);
    if (directory == NULL) {
        perror("Erro ao abrir o diretório");
        return 1;
    }

    struct dirent* entry;

    while ((entry = readdir(directory)) != NULL) {
        if (entry->d_type == DT_DIR) {
            if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
                // printf("%s\n", entry->d_name);
                char command[100];
                snprintf(command, sizeof(command), "(./tool-elf %s)",  entry->d_name);
                Command("", command, false);
            }
        }
    }

    closedir(directory);
}

void GeneratSimulation()
{
    fprintf(stdout, "[%s] Preparando arquivos para simulação\n", __func__);
    Command("", "./run-vvp", false);
}
