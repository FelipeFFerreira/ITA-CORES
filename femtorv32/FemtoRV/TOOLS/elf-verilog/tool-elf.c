#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#define CORE
#define BYTE 8

static FILE * mode_file(char file[], char mode[]) {
    FILE *fptr;
    if( (fptr = fopen(file, mode)) == NULL) {
        fprintf(stdout, "Error opening file [%s]!\n", file);
        exit(1);
    }
    return fptr;
}

int main(int argc, char *argv[])
{
    int cnt = 0, i = 0;
    char ch, byte[9], byte_verilog[9], file[50], file_destino[50], file_origem[50];
    const char* directory_path = "../../build/"; 

    if (argc > 1) {
        char *string = argv[1];

        snprintf(file, sizeof(file), "%s%s/%s.hex", directory_path, string, string);
        printf("[ Formatando arquivo para o teste [%s]  %s]\n", string, file);
        FILE* fptr1 = mode_file(file, "r");
        sprintf(file_destino, "%s%s/%s_firmware.hex", directory_path, string, string);
        FILE* fptr2 = mode_file(file_destino, "w");
        
        #ifdef SPI
            fprintf(fptr2, "\t%s\n", "always @(posedge reset_spi) begin");
        #endif // SPI

        bool lp = false;
        int lp_count = 0;
        do {
            ch = fgetc(fptr1);
            if (ch == '@' | lp == true)
            {
                if (++lp_count < BYTE + 1)
                    lp = true;
                else if (ch == '\n') 
                    lp = false;
            }
            else {
                if (ch != ' ' && ch != '\n' && ch != '\r' ) {
                    byte[cnt++] = ch;
                }

                if (cnt == BYTE) {
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
                    #ifdef SPI
                        printf("byte = %s\n", byte_verilog);
                        fprintf(fptr2, "\t\tMEM[%d] <= 32'h%s;\n", i++, byte_verilog);
                    #endif // SPI
                    #ifdef CORE
                        fprintf(fptr2, "%s\n", byte_verilog);
                    #endif // CORE
                    cnt = 0;
                }
            }
        } while(ch != EOF);
        #ifdef SPI
            fprintf(fptr2, "\t%s\n", "end");
        #endif // SPI
        fclose(fptr1);
        return 0;
    } else {
        printf("Nenhuma string fornecida como argumento.\n");
        return 1;
    }
}
