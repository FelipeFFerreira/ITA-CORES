#include <stdlib.h>
#include <stdio.h>

void Command(char *, char *);

int main() {

    char* scriptfilePath_tooltchain = "../../";
    char* scriptfilePath_scripts = "../";


    fprintf(stdout, "[%s] Processando arquivos para compilação\n", __func__);

    Command(scriptfilePath_tooltchain, "make clean");

    Command(scriptfilePath_tooltchain, "make riscv-formal");
    
    Command(scriptfilePath_tooltchain, "make hex");

    // Command(scriptfilePath_scripts, "make run-tools-elf:");



    return 0;
}

void Command(char * scriptfilePath, char * makeCommand)
{
    char command[100];

    snprintf(command, sizeof(command), "(cd %s && %s)", scriptfilePath, makeCommand);

    int result = system(command);

    if (result == 0) {
        printf("[%s] Comando executado sucesso.\n", __func__);
    } else {
        printf("[%s] Erro ao executar comando.\n", __func__);
    }

}
