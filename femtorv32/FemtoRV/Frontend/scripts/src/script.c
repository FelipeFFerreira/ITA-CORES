#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <stdbool.h>
#include <sys/types.h>
#include <string.h>
#include <unistd.h>
#include "definitions.h"

void Command(char *, char *, bool);

void MachineCodeTool();

void GeneratSimulation(char *);

void GeneratSimulationDevice();

int DisplayLoad(char * opcao[NUM_OP]);

int Display();

int main() {

#ifdef ENV_FRONTEND_SIGNOFF
    fprintf(stdout, "[%s] \nEnvironment For [SIMULATION] Configured\n", __func__);
#else
    fprintf(stdout, "[%s] \nEnvironment For [DEVICE] Configured\n", __func__);
#endif

    char* scriptfilePath_tooltchain = "../../";
    char* scriptfilePath_scripts = "../";

    int op = Display();

    // Automating TOOLCHAIN-RISC-V

    Command(scriptfilePath_tooltchain, "make clean", true);

    fprintf(stdout, "[%s] Installing TOOLCHAIN-RISCV - 32 bits\n", __func__);

    Command(scriptfilePath_tooltchain, "make toolchain", true);

    fprintf(stdout, "[%s] Processing Files For Compilation\n", __func__);
    
    char type_test[100];

#ifdef ENV_FRONTEND_SIGNOFF

    switch (op) {

    case COMPLIANCE_RISCV_ORG:
        printf(">>COMPLIANCE_RISCV_ORG\n");
        Command(scriptfilePath_tooltchain, "make riscv-tests RISCV-TESTS=1 ENV_FRONTEND_SIGNOFF=1", true);
        strcpy(type_test, "riscv-tests");
        break;
    
    case RISCV_SUITE_LOWRISCV:
        printf(">>RISCV_SUITE_LOWRISCV\n");
        Command(scriptfilePath_tooltchain, "make riscv-test-suite RISCV-TESTS-SUITE=1 ENV_FRONTEND_SIGNOFF=1", true);
        strcpy(type_test, "riscv-test-suite");
        break;

    case UNIT_TESTS:
        printf(">>UNIT_TESTS\n");
        break;

    case PERIPHERAL:
        printf(">>PERIPHERAL\n");
        break;
    
        default:
        printf( ">>Only the tools have been installed. Operation Canceled, because the informed test repository is invalid.\n!" );
        exit(10);
        } 
#else
        switch (op) {

        case COMPLIANCE_RISCV_ORG:
            printf(">>COMPLIANCE_RISCV_ORG\n");
            Command(scriptfilePath_tooltchain, "make riscv-tests", true);
            break;
        
        case RISCV_SUITE_LOWRISCV:
            printf(">>RISCV_SUITE_LOWRISCV\n");
            Command(scriptfilePath_tooltchain, "make riscv-test-suite", true);
            break;
        
        case UNIT_TESTS:
            printf(">>UNIT_TESTS\n");
            break;

        case PERIPHERAL:
            printf(">>PERIPHERAL\n");
            break;
        
         default:
            printf( ">>Only the tools have been installed. Operation Canceled, because the informed test repository is invalid.\n!" );
            exit(10);
        } 
#endif

    Command(scriptfilePath_tooltchain, "make hex", true);

    // Automating Tools
    fprintf(stdout, "[%s] Compiling tools\n", __func__);

    Command(scriptfilePath_scripts, "make run-tools-elf", true);

    Command(scriptfilePath_scripts, "make run-tools-elf-flash", true);
    
    Command(scriptfilePath_scripts, "make run-vvp", true);

    fprintf(stdout, "[%s] Preparando arquivos para formatação\n", __func__);

    MachineCodeTool();
    
#ifdef ENV_FRONTEND_SIGNOFF
    GeneratSimulation(type_test);
#endif

    fprintf(stdout, "[%s] Gerando arquivos binarios de cada teste\n", __func__);

    Command(scriptfilePath_tooltchain, "make bin", true);

#ifndef ENV_FRONTEND_SIGNOFF
    fprintf(stdout, "[%s] Preparando simulações para o device\n", __func__);
    // GeneratSimulationDevice(); 
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

void GeneratSimulation(char *type_test)
{
    char command[100];
    fprintf(stdout, "[%s] Preparando arquivos para simulação\n", __func__);
    snprintf(command, sizeof(command), "./run-vvp %s", type_test);
    Command("", command, false);
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

int DisplayLoad(char * opcao[NUM_OP]) 
{
    int i, op;
    printf("\n[ Choose the desired repository for designing and running the tests ]\n");
    for (i = 0; i < NUM_OP; i++) {
        printf("%-30s\t\t\tOP:%d\n", opcao[i], i + 1);
    }
    printf("\n[Choose an option]: ");
    scanf(" %d", &op);
    return op;
}

int Display()
{
    char * opcoes[NUM_OP] = { "Compliance Tests [riscv.org]",
                              "RISC-V TEST SUITE [lowRISCV]",
                              "Unit Tests", 
                              "Peripheral tests",
                            };
    int op;

    return op = DisplayLoad(opcoes);
}
