#include <stdio.h>

int onePlusOne() { return 1 + 1; }

int main() {
    int two = onePlusOne();

    printf("1 + 1 = %d\n", two);

    return 0;
}
