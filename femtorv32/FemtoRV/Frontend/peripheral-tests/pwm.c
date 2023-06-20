// #include <femtorv32.h>

int main() {
	
	while (1) {

		for (unsigned i = 0; i < 200; i++) {
			*(volatile unsigned int*)(0x404000) = i;
			// delay(1);
		}   
	}	
	return 0;
}