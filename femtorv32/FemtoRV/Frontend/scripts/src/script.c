#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <stdbool.h>
#include <sys/types.h>
#include <string.h>
#include <unistd.h>

#define ENV_FRONTEND_SIGNOFF

void Command(char *, char *, bool);

void MachineCodeTool();

void GeneratSimulation();

void GeneratSimulationDevice();


int main() {

    char* scriptfilePath_tooltchain = "../../";
    char* scriptfilePath_scripts = "../";

    // Automating TOOLCHAIN-RISC-V

    Command(scriptfilePath_tooltchain, "make clean", true);

    fprintf(stdout, "[%s] Fazendo a instalação da TOOLCHAIN-RISCV-32b\n", __func__);

    Command(scriptfilePath_tooltchain, "make toolchain", true);

    fprintf(stdout, "[%s] Processando arquivos para compilação\n", __func__);

    Command(scriptfilePath_tooltchain, "make riscv-tests", true);
    
    Command(scriptfilePath_tooltchain, "make hex", true);

    // Automating Tools
    fprintf(stdout, "[%s] Compilando ferramentas\n", __func__);

    Command(scriptfilePath_scripts, "make run-tools-elf", true);

    Command(scriptfilePath_scripts, "make run-tools-elf-flash", true);
    
    Command(scriptfilePath_scripts, "make run-vvp", true);

    fprintf(stdout, "[%s] Preparando arquivos para formatação\n", __func__);

    MachineCodeTool();

    GeneratSimulation();

    fprintf(stdout, "[%s] Gerando arquivos binarios de cada teste\n", __func__);

    Command(scriptfilePath_tooltchain, "make bin", true);

#ifndef ENV_FRONTEND_SIGNOFF
    fprintf(stdout, "[%s] Preparando simulações para o device\n", __func__);

    GeneratSimulationDevice();
#endif

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
                snprintf(command, sizeof(command), "(./tool-elf-flash %s)",  entry->d_name);
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

void GeneratSimulationDevice()
{
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
                printf("[%s] Executando simulação do teste [%s] no Device:\n", __func__, entry->d_name);
                char dir_path[100], command[100];
                snprintf(dir_path, sizeof(dir_path), "%s%s", directory_path, entry->d_name);
                snprintf(command, sizeof(command), "sudo icesprog -w -o 0x00020000 %s.bin", entry->d_name);
                printf("path: %s | comando: %s\n", dir_path, command);
                Command(dir_path, command, true);
                printf("Aguardando ...\n");
                sleep(5);
            }
        }
    }

    closedir(directory);
}