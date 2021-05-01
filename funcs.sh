
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

# Se o sistema for Linux, remover caractere unicode.
OS="$(uname)"
if [[ "$OS" == "Linux" ]]; then
    LINEBREAK='\n\t\t\t\t'
fi

echoeval() {
    echo "${PURPLE}$ $1${NOCOLOR}"
    eval $1
}

alias out="echoeval ./.a.out"

crun() {
    echoeval "gcc -ansi -pedantic -Wall -fexceptions -g -o .a.out $1" && out
}

cnew() {
    cp ~/.template.c $1.c
}

ctempl() {
    cp $1 ~/.template.c
}

cpprun() {
    echoeval "g++ -std=c++11 -pedantic -Wall -fexceptions -g -o .a.out $1" && out
}

cppnew() {
    cp ~/.template.cpp $1.cpp
}

cpptempl() {
    cp $1 ~/.template.cpp
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

${GREEN}ctempl ${LIGHTBLUE}[nome do arquivo.c]${NOCOLOR}\tredefine o template inicial para arquivos C.

${GREEN}cpptempl ${LIGHTBLUE}[nome do arquivo.cpp]${NOCOLOR}\tredefine o template inicial para arquivos C++.

${GREEN}hidevscc${NOCOLOR}\t\t\tcaso esteja usando VS Code, este comando torna invisíveis os${LINEBREAK}arquivos de compilação para não poluir a área de trabalho.
"
    printf "\n${INSTRUCTIONS}\n"
    printf "${TTYBOLD}Better C/C++ Compilation Tools v${BETTERCCPPVERS}${TTYRESET} - feito por ${LIGHTBLUE}@henriquefalconer${NOCOLOR} (https://github.com/henriquefalconer)\n\n"
    printf "Sugestões ou problemas podem ser submetidos aqui: ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-compilation-tools/issues${TTYRESET}\n\n"
}

# ------ End of Better C/C++ Compilation Tools ------
