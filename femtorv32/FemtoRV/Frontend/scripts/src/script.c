#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <stdbool.h>
#include <sys/types.h>
#include <string.h>
#include <unistd.h>
#include "definitions.h"
#include <time.h>

void Command(char *, char *, bool);

void MachineCodeTool();

void GeneratSimulation(char *);

void GeneratSimulationDevice();

int DisplayLoad(char * opcao[NUM_OP]);

int Display();

void Loading();

int main() {

    system("clear"); 
    // Header
    printf("\033[1;36m-----------------------------------------\n");
    printf("          Setup Environment\n");
    printf("-----------------------------------------\033[0m\n\n"); 
#ifdef ENV_FRONTEND_SIGNOFF
    printf("\033[1;32m[%s]\033[0m \n\nEnvironment For \033[1;34m[SIMULATION]\033[0m Configured\n", __func__);
#else
    printf("\033[1;32m[%s]\033[0m \n\nEnvironment For \033[1;34m[DEVICE]\033[0m Configured\n", __func__);
#endif

    char* scriptfilePath_tooltchain = "../../";
    char* scriptfilePath_scripts = "../";

    int op = Display();

    // Automating TOOLCHAIN-RISC-V

    Command(scriptfilePath_tooltchain, "make clean", true);

    fprintf(stdout, "\033[1;32m[%s] Installing TOOLCHAIN-RISCV - 32 bits\033[0m\n", __func__);

    Command(scriptfilePath_tooltchain, "make toolchain", true);

    fprintf(stdout, "\033[1;34m[%s] Processing Files For Compilation\033[0m\n", __func__);
    
    char type_test[100];

#ifdef ENV_FRONTEND_SIGNOFF

    switch (op) {
        case COMPLIANCE_RISCV_ORG:
            Command(scriptfilePath_tooltchain, "make clean TESTDIR=riscv-tests", true);
            printf("\033[1;34m>>COMPLIANCE_RISCV_ORG\033[0m\n");
            Loading();
            Command(scriptfilePath_tooltchain, "make riscv-tests TESTDIR=riscv-tests ENV_FRONTEND_SIGNOFF=1", true);
            strcpy(type_test, "riscv-tests");
            break;
        
        case RISCV_SUITE_LOWRISCV:
            Command(scriptfilePath_tooltchain, "make clean TESTDIR=riscv-test-suite", true);
            printf("\033[1;34m>>RISCV_SUITE_LOWRISCV\033[0m\n");
            Loading();
            Command(scriptfilePath_tooltchain, "make riscv-test-suite TESTDIR=riscv-test-suite ENV_FRONTEND_SIGNOFF=1", true);
            strcpy(type_test, "riscv-test-suite");
            break;

        case PERIPHERAL:
            Command(scriptfilePath_tooltchain, "make clean TESTDIR=peripheral-tests", true);
            Loading();
            printf("\033[1;34m>>TESTS_FOR_PERIPHERALS\033[0m\n");
            Command(scriptfilePath_tooltchain, "make peripheral-tests TESTDIR=peripheral-tests ENV_FRONTEND_SIGNOFF=1", true);
            break;

        case UNIT_TESTS:
            Command(scriptfilePath_tooltchain, "make clean TESTDIR=peripheral-tests", true);
            Loading();
            printf("\033[1;34m>>UNIT_TESTS\033[0m\n");
            Command(scriptfilePath_tooltchain, "make peripheral-tests TESTDIR=peripheral-tests", true);
            strcpy(type_test, "peripheral-tests");
            break;

        case GENERAL_PROGRAMS:
            Command(scriptfilePath_tooltchain, "make clean TESTDIR=peripheral-tests", true);
            Loading();
            printf("\033[1;34m>>GENERAL_PROGRAMS\033[0m\n");
            printf("\033[1;33m>Currently only supported for devices that use external flash. Go to the directory 'Program_Test'\033[0m\n");
            exit(2);
            break;
        
        default:
            printf("\033[1;31m>Only the tools have been installed. Operation Canceled, because the provided test repository is invalid!\033[0m\n");
            exit(10);
        } 
#else
        switch (op) {

            case COMPLIANCE_RISCV_ORG:
                Command(scriptfilePath_tooltchain, "make clean TESTDIR=riscv-tests", true);
                printf(">>COMPLIANCE_RISCV_ORG\n");
                Loading();
                Command(scriptfilePath_tooltchain, "make riscv-tests TESTDIR=riscv-tests", true);
                break;
            
            case RISCV_SUITE_LOWRISCV:
                Loading();
                printf(">Não Suportado\n");
                exit(10);
                break;
            
        case PERIPHERAL:
            Command(scriptfilePath_tooltchain, "make clean TESTDIR=peripheral-tests", true);
            Loading();
            printf("\033[1;34m>>TESTS_FOR_PERIPHERALS\033[0m\n");
            Command(scriptfilePath_tooltchain, "make peripheral-tests TESTDIR=peripheral-tests ENV_FRONTEND_SIGNOFF=1", true);
            break;

        case UNIT_TESTS:
            Command(scriptfilePath_tooltchain, "make clean TESTDIR=peripheral-tests", true);
            Loading();
            printf("\033[1;34m>>UNIT_TESTS\033[0m\n");
            Command(scriptfilePath_tooltchain, "make peripheral-tests TESTDIR=peripheral-tests", true);
            strcpy(type_test, "peripheral-tests");
            break;

        case GENERAL_PROGRAMS:
            Command(scriptfilePath_tooltchain, "make clean TESTDIR=peripheral-tests", true);
            Loading();
            printf("\033[1;34m>>GENERAL_PROGRAMS\033[0m\n");
            printf("\033[1;33m>Currently only supported for devices that use external flash. Go to the directory 'Program_Test'\033[0m\n");
            exit(2);
            break;
        
        default:
            printf("\033[1;31m>Only the tools have been installed. Operation Canceled, because the provided test repository is invalid!\033[0m\n");
            exit(10);
        } 
#endif

    Command(scriptfilePath_tooltchain, "make hex", true);

    // Automating Tools
    fprintf(stdout, "\033[1;34m[%s] Compiling tools\033[0m\n", __func__);

    Command(scriptfilePath_scripts, "make run-tools-elf", true);

    Command(scriptfilePath_scripts, "make run-tools-elf-flash", true);
    
    Command(scriptfilePath_scripts, "make run-vvp", true);

    fprintf(stdout, "\033[1;34m[%s] Preparing files for formatting\033[0m\n", __func__);

    MachineCodeTool();
    
#ifdef ENV_FRONTEND_SIGNOFF
    GeneratSimulation(type_test);
#endif

    fprintf(stdout, "\033[1;34m[%s] Generating binary files for each test\033[0m\n", __func__);

    Command(scriptfilePath_tooltchain, "make bin", true);

#ifndef ENV_FRONTEND_SIGNOFF
    fprintf(stdout, "\033[1;34m[%s] Preparing simulations for the device\033[0m\n", __func__);
    GeneratSimulationDevice(); 
#endif

    printf("\n\033[1;36m-----------------------------------------\n");
    printf("            End of Process\n");
    printf("-----------------------------------------\033[0m\n");

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
            printf("\033[1;32mMakefile completed successfully!\033[0m\n");
        } else {
            printf("\033[1;31mError during Makefile execution.\033[0m\n");
        }
    } else {
        printf("\033[1;31mError executing the 'make programa' command.\033[0m\n");
    }
}

void MachineCodeTool() {
    const char* directory_path = "../../build/"; 

    DIR* directory = opendir(directory_path);
    if (directory == NULL) {
        perror("Error opening the directory");
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
    printf("\033[1;32m[%s]\033[0m Preparing files for simulation\n", __func__);
    snprintf(command, sizeof(command), "./run-vvp %s", type_test);
    Command("", command, false);
}

void GeneratSimulationDevice()
{
    const char* directory_path = "../../build/"; 

    DIR* directory = opendir(directory_path);
    if (directory == NULL) {
        perror("Error opening the directory");
        return 1;
    }

    struct dirent* entry;

    while ((entry = readdir(directory)) != NULL) {
        if (entry->d_type == DT_DIR) {
            if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
                printf("[%s] Running simulation test [%s] on Device:\n", __func__, entry->d_name);
                char dir_path[100], command[100];
                snprintf(dir_path, sizeof(dir_path), "%s%s", directory_path, entry->d_name);
                snprintf(command, sizeof(command), "sudo icesprog -w -o 0x00020000 %s.bin", entry->d_name);
                printf("\033[1;34mpath:\033[0m %s \033[1;34m|\033[0m \033[1;34mcommand:\033[0m %s\n\033[0m", dir_path, command);
                Command(dir_path, command, true);
                printf("\033[1;33mWaiting...\033[0m\n");
                sleep(5);
            }
        }
    }

    closedir(directory);
}

int DisplayLoad(char * opcao[NUM_OP]) 
{
    int i, op;
    int width = 50;
    printf("\n");
    printf("\033[1;34m"); 
    for (i = 0; i < width; i++) {
        printf("=");
    }
    printf("\n\033[0m"); 

    int padding = (width - strlen("[ Choose the desired repository for designing and running the tests ]")) / 2;
    printf("\033[1;34m=\033[0m");
    for (i = 0; i < padding - 1; i++) printf(" ");
    printf("\033[1;32m[ Choose the desired repository for designing and running the tests ]\033[0m");
    for (i = 0; i < padding - 1; i++) printf(" ");
    printf("\033[1;34m=\033[0m\n");

    // Opções
    for (i = 0; i < NUM_OP; i++) {
        printf("\033[1;34m=\033[0m \033[1;36m%-30s\033[0m\t\t\t\033[1;31mOP:%d\033[0m \033[1;34m=\033[0m\n", opcao[i], i + 1);
    }
    printf("\033[1;34m"); 
    for (i = 0; i < width; i++) {
        printf("=");
    }
    printf("\033[0m\n"); 
    printf("\n\033[1;37m[Choose an option]: \033[0m");
    scanf(" %d", &op);
    return op;
}

int Display()
{
    char * opcoes[NUM_OP] = { "RISC-V compliance tests[©]\t",
                              "lowRISC compliance tests",
                              "tests for peripherals", 
                              "unit tests",
                              "general programs",
                            };
    int op;

    return op = DisplayLoad(opcoes);
}
void Loading()
{
    #define BAR_LENGTH 50 

    for (int i = 0; i <= BAR_LENGTH; i++) {
        printf("[");
        
        for(int j = 0; j < i; j++)
            printf("#");
            
        for(int j = i; j < BAR_LENGTH; j++)
            printf(" ");
            
        printf("]\r");
        fflush(stdout);
        
        usleep(5000000/BAR_LENGTH);
    }
    printf("\n");
}