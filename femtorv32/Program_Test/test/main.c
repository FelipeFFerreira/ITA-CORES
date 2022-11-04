
#include <femtorv32.h>

int main() {
	
    unsigned int a, b, aux, i, cnt = 0;

	a = 1;
    b = 0;

	while (1) {

		for (i = 0; i < 15; i++) {
			
			aux = a + b;
			a = b;
			b = aux;
			printf(" %d ,", aux);

			for (unsigned i = 0; i < 4096; i++) {
				*(volatile uint32_t*)(0x404000) = i;
				delay(1);
			} 
		}

		a = 1;
   		b = 0;
		printf("\r\n");
		printf("%d. [ITA-RVITA]\r\n", cnt++);
	}	

	return 0;
}
