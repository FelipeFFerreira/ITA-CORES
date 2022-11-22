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
    FILE* fptr1 = mode_file("my_verilog_flash.hex","r");
    FILE* fptr2 = mode_file("verilog_my_verilog_flash.hex","w");
    int cnt = 0;
    char ch, byte[9], byte_verilog[9];

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
            fprintf(fptr2, "%s\n", byte_verilog);
            cnt = 0;

        }


    } while(ch != EOF);
    return 0;
}
