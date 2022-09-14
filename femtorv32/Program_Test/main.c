
#include <femtorv32.h>

int main()
{
	unsigned int i = 0;
	while (1) {
		i += 2;
		printf("%d. [ITA-]\r\n", i);
		printf(" ** Testando - UART! [ITA_CORES] ***\r\n");
		printf("Freq: %d MHz\r\n", FEMTORV32_FREQ);
		delay(10);
	}
	return 0;

}
