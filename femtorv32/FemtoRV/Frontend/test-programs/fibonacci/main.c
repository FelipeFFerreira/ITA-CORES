
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