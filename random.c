#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char const * const alpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
char const * const alnum = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
char const * const base32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
char const * const xdigit = "0123456789abcdef";
char const * const digit = "0123456789";

void randomize(char * const result, int const size, char const * const alphabet) {
	size_t const alphabet_size = strlen(alphabet);
	for (int i = 0; i < size; ++i) {
		result[i] = alphabet[(int)((double)rand() / RAND_MAX * alphabet_size)];
	}

	result[size] = 0;
}

char const * const get_alphabet(char const * const mode) {
	if (strstr(mode, "alpha")) return alpha;
	else if (strstr(mode, "alnum")) return alnum;
	else if (strstr(mode, "base32")) return base32;
	else if (strstr(mode, "xdigit")) return xdigit;
	else if (strstr(mode, "digit")) return digit;
	else return NULL;
}

int main(int argc, char** argv) {
	if (argc != 3) {
		puts("Usage: LEN alnum|alpha|base32|xdigit|digit");
		return 1;
	}

	int size = atoi(argv[1]);
	char const * const alphabet = get_alphabet(argv[2]);
	if (alphabet == NULL) {
		printf("ERROR, unknown mode '%s'\n", argv[2]);
		return 1;
	}

	srand(arc4random());

	char* result = malloc(size + 1);
	randomize(result, size, alphabet);
	puts(result);

	free(result);
}
