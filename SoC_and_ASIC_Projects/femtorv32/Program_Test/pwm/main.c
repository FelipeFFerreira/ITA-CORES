
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
	
//	unsigned int cnt = 0;
	while (1) {

		for (unsigned i = 0; i < 4096; i++) {
			*(volatile unsigned int*)(0x404000) = i;
			delay(1);
		}   
		
//		printf("%d. [ITA-RVITA]\r\n", cnt++);
		// cnt = cnt >= 1000 ? 0 : cnt;    	     
	}	

	return 0;
}
