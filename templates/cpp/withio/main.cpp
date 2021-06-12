#include "iofuncs.h"

void teste() {
    int number = input<int>("Quanto vale 1 + 1? ");
    string nome = input("Digite seu nome: ", '\n');

    print("Segundo o ", nome, ", 1 + 1 = ", number);
}

int main() {
    teste();
    return 0;
}
