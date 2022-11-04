
// #include <femtorv32.h>

// int main()
// {
// 	unsigned int i = 0;
// 	while (1) {
		
// 		// i += 2;
// 		// printf("%d. [ITA-RVITA]\r\n", i++);
// 		// printf("Freq: %d MHz\r\n", FEMTORV32_FREQ);
// 		// *(volatile uint32_t*) (0x400004) = 1;
// 		// delay(200);
// 		// *(volatile uint32_t*) (0x400004) = 0;
// 		// delay(200);
// 		// printf(" ** Testando - UART! [ITA_CORES] ***\r\n");
// 		// printf("Freq: %d MHz\r\n", FEMTORV32_FREQ);
// 		// delay(200);
// 		// for (unsigned int i = 0; i < 10; i++) {
//         // if (i < 2) printf("\t***\t**************\t***********");
//         // else  printf("\t***\t     ****\t***\t***");
//         // if (i == 4) printf("\n\t***\t     ****\t***********");
//         // printf("\n");
//    }
	
// 	return 0;

// }

#include <femtorv32.h>

int main() {
  
    unsigned int a, b, aux, i, cnt = 0;

    a = 1;
    b = 0;
	while (1) 
	{
		for (i = 0; i < 15; i++) {
			aux = a + b;
			a = b;
			b = aux;
			printf(" %d ,", aux);
			delay(20);
		}
		a = 1;
   		b = 0;
		// cnt = cnt >= 231 ? 0 : cnt;
		printf("\r\n%d. ", cnt++);
		printf("\r\n");
	}
}