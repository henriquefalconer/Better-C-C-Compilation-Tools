#!/bin/bash

echoeval() {
	PURPLE='\e[0;35m'
	NOCOLOR='\e[0m'
	echo "${PURPLE}$ $1${NOCOLOR}"
	eval $1
}

out() {
	echoeval ./.a.out
}

crun() {
	echoeval "gcc -ansi -pedantic -Wall -fexceptions -g -o .a.out $1" && out
}

cnew() {
	printf '#include <stdio.h>\n\nint onePlusOne() { return 1 + 1; }\n\nint main() {\n	int two = onePlusOne();\n\n	printf("1 + 1 = %%d%s", two);\n\n	return 0;\n}\n' '\n' > $1.c
}

cpprun() {
	echoeval "g++ -std=c++11 -pedantic -Wall -fexceptions -g -o .a.out $1" && out
}

cppnew() {
	echo '#include <iostream>\n#include <string>\n\nusing namespace std;\n\nstring exercicio() { return "Hello world!"; }\n\nint main() {\n	cout << exercicio();\n\n	return 0;\n}' > $1.cpp
}

hidevscc() {
	[ -d .vscode ] || mkdir .vscode; echo '{\n	"files.exclude": {\n		".a.out.dSYM": true,\n		".a.out": true\n	}\n}' > .vscode/settings.json
}

chelp() {
	GREEN='\e[32m'
	LIGHTBLUE='\e[94m'
	LIGHTGREY='\e[37m'
	NOCOLOR='\e[0m'
	LINEBREAK='\n\t\t\t\t⮑  '
	if [ "$1" = "new" ]; then
		echo '\n🎉 Foram criados os seguintes comandos!'
	else 
		echo '\nComandos para rodar programas em C/C++! 💻'
	fi
   INSTRUCTIONS="
${GREEN}cnew ${LIGHTBLUE}[nome do arquivo]${NOCOLOR}\t\tgera um novo arquivo C na pasta atual, com um template inicial.

${GREEN}crun ${LIGHTBLUE}[nome do arquivo.c]${NOCOLOR}\tcompila e roda um código em C (use TAB para completar o nome${LINEBREAK}do arquivo ao escrever na linha de comando).

${GREEN}cppnew ${LIGHTBLUE}[nome do arquivo]${NOCOLOR}\tgera um novo arquivo C++ na pasta atual, com um template inicial.

${GREEN}cpprun ${LIGHTBLUE}[nome do arquivo.cpp]${NOCOLOR}\tcompila e roda um código em C++ (use TAB para completar o nome${LINEBREAK}do arquivo ao escrever na linha de comando).

${GREEN}out${NOCOLOR}\t\t\t\troda o último código em C/C++ compilado com ${LIGHTBLUE}crun${NOCOLOR} ou ${LIGHTBLUE}cpprun${NOCOLOR} na${LINEBREAK}pasta atual.

${GREEN}hidevscc${NOCOLOR}\t\t\tcaso esteja usando VS Code, este comando torna invisíveis os${LINEBREAK}arquivos de compilação para não poluir a área de trabalho.
"
	echo "\n${INSTRUCTIONS}\n"
	[ "$1" = "new" ] && echo "Para visualizar este menu novamente, é só digitar ${LIGHTBLUE}chelp${NOCOLOR} 😉\n"
	echo "Feito por ${LIGHTBLUE}@henriquefalconer${NOCOLOR} (https://github.com/henriquefalconer)\n"
}