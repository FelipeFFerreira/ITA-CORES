int main() {
	while (1) {

		for (unsigned i = 0; i < 4096; i++) {
			*(volatile unsigned int*)(0x404000) = i;
		}
	}
}