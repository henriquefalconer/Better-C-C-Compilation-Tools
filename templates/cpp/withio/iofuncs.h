#include <iostream>
#include <string>
using namespace std;

// Imprime na saída padrão todos os argumentos passados.
inline void printinl() {}

// Imprime na saída padrão todos os argumentos passados.
template <typename T, typename... Args>
inline void printinl(T t, Args... args) {
    cout << t;
    printinl(args...);
}

// Imprime na saída padrão todos os argumentos passados, adicionando uma quebra de linha no fim da sequência.
// Obs.: Caso você não queira que seja impressa a quebra de linha, utilize a função printinl.
template <typename... Args>
inline void print(Args... args) {
    printinl(args..., '\n');
}

// Lê o texto digitado na entrada padrão, retornando-o por padrão em forma de string.
// Obs.: Para retornar uma variável cujo tipo que não é string, especificar no argumento de template: int i = input<int>();
// Opcionalmente, também imprime um texto após a leitura, tal como uma quebra de linha.
template <typename T = string, typename U = string, typename V = string>
inline T input(U textbefore = "", V textafter = "") {
    T t;
    printinl(textbefore);
    cin >> t;
    printinl(textafter);
    return t;
}

// Lê o texto digitado na entrada padrão, retornando true se for igual a "s" ou "", e false caso contrário.
// Opcionalmente, também imprime um texto após a leitura, tal como uma quebra de linha.
template <typename U = string, typename V = string>
inline bool simounao(U textbefore = "", V textafter = "") {
    string escolha = input(textbefore, textafter);
    return escolha == "s" || escolha.empty();
}
