
# ------ Start of Better C/C++ Compilation Tools ------

BETTERCCPPVERS='1.0'

# Formatação de strings
LIGHTBLUE='\e[94m'
PURPLE='\e[0;35m'
GREEN='\e[32m'
NOCOLOR='\e[0m'
TTYBOLD='\033[1;39m'
TTYRESET='\033[1;0m'
LINEBREAK='\n\t\t\t\t⮑  '

echoeval() {
    echo "${PURPLE}$ $1${NOCOLOR}"
    eval $1
}

alias out="echoeval ./.a.out"

crun() {
    echoeval "gcc -ansi -pedantic -Wall -fexceptions -g -o .a.out $1" && out
}

cnew() {
    cat >$1.c <<-END
		#include <stdio.h>

		int onePlusOne() { return 1 + 1; }

		int main() {
		    int two = onePlusOne();

		    printf("1 + 1 = %%d\n", two);

		    return 0;
		}
	END
}

cpprun() {
    echoeval "g++ -std=c++11 -pedantic -Wall -fexceptions -g -o .a.out $1" && out
}

cppnew() {
    cat >$1.cpp <<-END
		#include <iostream>
		#include <string>

		using namespace std;

		string exercicio() { return "Hello world!"; }

		int main() {
		    cout << exercicio();

		    return 0;
		}
	END
}

hidevscc() {
    code -g .vscode/settings.json:4:23
    [ -d .vscode ] || mkdir .vscode
    cat >.vscode/settings.json <<-END
		{
		    "files.exclude": {
		        ".a.out.dSYM": true,
		        ".a.out": true
		    }
		}
	END
}

chelp() {
    printf "\nComandos para rodar programas em C/C++! 💻"
    INSTRUCTIONS="
${GREEN}cnew ${LIGHTBLUE}[nome do arquivo]${NOCOLOR}\t\tgera um novo arquivo C na pasta atual, com um template inicial.

${GREEN}crun ${LIGHTBLUE}[nome do arquivo.c]${NOCOLOR}\tcompila e roda um código em C (use ${TTYBOLD}TAB${TTYRESET} para completar o nome${LINEBREAK}do arquivo ao escrever na linha de comando).

${GREEN}cppnew ${LIGHTBLUE}[nome do arquivo]${NOCOLOR}\tgera um novo arquivo C++ na pasta atual, com um template inicial.

${GREEN}cpprun ${LIGHTBLUE}[nome do arquivo.cpp]${NOCOLOR}\tcompila e roda um código em C++ (use ${TTYBOLD}TAB${TTYRESET} para completar o nome${LINEBREAK}do arquivo ao escrever na linha de comando).

${GREEN}out${NOCOLOR}\t\t\t\troda o último código em C/C++ compilado com ${LIGHTBLUE}crun${NOCOLOR} ou ${LIGHTBLUE}cpprun${NOCOLOR} na${LINEBREAK}pasta atual.

${GREEN}hidevscc${NOCOLOR}\t\t\tcaso esteja usando VS Code, este comando torna invisíveis os${LINEBREAK}arquivos de compilação para não poluir a área de trabalho.
"
    printf "\n${INSTRUCTIONS}\n"
    printf "${TTYBOLD}Better C/C++ Compilation Tools v${BETTERCCPPVERS}${TTYRESET} - feito por ${LIGHTBLUE}@henriquefalconer${NOCOLOR} (https://github.com/henriquefalconer)\n\n"
    printf "Sugestões ou problemas podem ser submetidos aqui: ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-compilation-tools/issues${TTYRESET}\n\n"
}

# ------ End of Better C/C++ Compilation Tools ------
