#include <stdio.h>

int main() {
    printf("Preparando saída de teste\n");
    FILE *inputFile = fopen("output_vvp", "r");  
    FILE *outputFile = fopen("avaliar_test", "w"); 
    if (inputFile == NULL || outputFile == NULL) {
        printf("Erro ao abrir os arquivos.\n");
        return 1;
    }

    int ch;
    while ((ch = fgetc(inputFile)) != EOF) {
        if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z')) {
            fprintf(outputFile, "%c", ch);
        }
    }

    fclose(inputFile);
    fclose(outputFile);
    return 0;
}
