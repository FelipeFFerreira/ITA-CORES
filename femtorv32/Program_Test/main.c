
#include <femtorv32.h>

int main()
{
	int a = 0;
	while (1) {
		printf("%d. [Continua no cadence!!!]\n", a++);
		printf(" ********* Testando - UART! [ITA_CORES] ***********\r\n");
		printf("Freq: %d MHz\r\n", FEMTORV32_FREQ);
		delay(1000);
	}
	return 0;

}
