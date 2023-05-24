#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

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
    int cnt = 0, i = 0;
    char ch, byte[9], byte_verilog[9], file[26], file_destino[50], file_origem[50];

    printf("Arquivo .hex: ");
    scanf(" %50[^\n]", file);
   // sprintf(file_origem, "verilogs-to-convert%s", file);
    FILE* fptr1 = mode_file(file, "r");
    sprintf(file_destino, "firmware-%s", file);
    FILE* fptr2 = mode_file(file_destino, "w");
    fprintf(fptr2, "\t%s\n", "always @(posedge reset_spi) begin");


    do {
        ch = fgetc(fptr1);
        if (ch != ' ' && ch != '\n') {
            byte[cnt++] = ch;
        }
        if (cnt == 8) {
            byte[cnt++] = '\0';
            byte_verilog[0] = byte[6];
            byte_verilog[1] = byte[7];
            byte_verilog[2] = byte[4];
            byte_verilog[3] = byte[5];
            byte_verilog[4] = byte[2];
            byte_verilog[5] = byte[3];
            byte_verilog[6] = byte[0];
            byte_verilog[7] = byte[1];
            byte_verilog[8] = '\0';

            printf("byte = %s\n", byte_verilog);
            fprintf(fptr2, "\t\tMEM[%d] <= 32'h%s;\n", i++, byte_verilog);
            cnt = 0;
        }
    } while(ch != EOF);
    fprintf(fptr2, "\t%s\n", "end");
    return 0;
}
