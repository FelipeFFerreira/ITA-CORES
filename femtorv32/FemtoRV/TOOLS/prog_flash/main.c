#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

static FILE * mode_file(char file[], char mode[]) {
    FILE *fptr;
    if( (fptr = fopen(file, mode)) == NULL) {
        fprintf(stdout, "Error opening file [%s]!\n", file);
        exit(1);
    }
    return fptr;
}

int main()
{
    FILE* fptr1 = mode_file("verilog_my_verilog_flash_invertido.txt","r");
    FILE* fptr2 = mode_file("prog_flash_invertido.txt","w");
    char str[1000][50];
    int len_str = 0;
     while (!feof(fptr1)) {
        if (fgets(str[len_str], 9, fptr1)) {
            //printf("str = %s", str[len_str]);
            //system("pause");
            if (str[len_str][0] != '\n') {
                char word_resul[30];
                sprintf(word_resul, "MEM[%d] <= 32'h%s;\n", len_str, str[len_str]);
                fprintf(fptr2, word_resul);
                printf("str_word = %s", word_resul);
                len_str += 1;
            }
        }
     }
    return 0;
}
