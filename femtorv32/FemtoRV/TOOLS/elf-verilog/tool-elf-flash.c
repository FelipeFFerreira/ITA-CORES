#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#define SPI
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
    int count = 0;
    char file[50], file_destino[50], file_origem[50], linha[2000][2000], linha_h[1000];
    const char* directory_path = "../../build/"; 
    const char* directory_path_file_base = "../../../TOOLS/elf-verilog/test_interface_spi_base/flash_spi.v";

    if (argc > 1) {
        char *string = argv[1];

        snprintf(file, sizeof(file), "%s%s/%s_firmware.hex", directory_path, string, string);
        printf("\033[1;34m[ Generating SPI-FLASH synthesis file\033[0m \033[1;35m[%s]\033[0m \033[1;34m]\033[0m\n", string);
        FILE* fptr1 = mode_file(file, "r");
        sprintf(file_destino, "%s%s/%s_firmware_spi.v", directory_path, string, string);
        FILE* fptr2 = mode_file(file_destino, "w");

        FILE* fptr3 = mode_file(directory_path_file_base, "r");
        while (!feof(fptr3)) {
            if (fgets(linha[count], 1000, fptr3)) {
            }
            count += 1;
        }
        fclose(fptr3);

        for (int j = 0; j < count; j++) {
            if (strstr(linha[j], "CMD_TEST_INTERFACE_SPI")) {
                fprintf(fptr2, "\tinitial begin\n");
                break;
            }
            else 
                fprintf(fptr2, linha[j]);
        }
        count = 0;
        while (!feof(fptr1)) {
            if (fgets(linha_h, sizeof(linha_h), fptr1)) {
                linha_h[strlen(linha_h) - 1] = '\0';
                fprintf(fptr2, "\t\tMEM[%d] <= 32'h%s;\n", count++, linha_h);
            }         
        }

        fprintf(fptr2, "\tend\nendmodule");
        
        fclose(fptr1);
        fclose(fptr2);
    } 
}
