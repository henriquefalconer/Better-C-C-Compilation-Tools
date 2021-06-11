#include "iofuncs.h"

void exercicio() {
    string nome = input("Digite seu nome: ");
    int repeticoes = input<int>("Digite um numero: ", '\n');

    for (int i = 0; i < repeticoes; i++)
        print("Ola ", nome, ' ', i + 1);
}

int main() {
    exercicio();
    return 0;
}
