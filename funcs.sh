
# ------ Start of Better C/C++ Tools ------

BETTERCCPPVERS='1.0'

# Formatação de strings
LIGHTBLUE='\e[94m'
PURPLE='\e[0;35m'
GREEN='\e[32m'
NOCOLOR='\e[0m'
TTYBOLD='\033[1;39m'
TTYRESET='\033[1;0m'
LINEBREAK='⮑  '

# Se o sistema for Linux, remover caractere unicode.
OS="$(uname)"
if [[ "$OS" == "Linux" ]]; then
    LINEBREAK=''
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

printcommand() {
    NAME="${GREEN}$1 ${LIGHTBLUE}$2${NOCOLOR}"
    TABSNO=4
    TABS=$(printf '\t%.0s' {1..${TABSNO}})
    REALNAMESIZE=$(($#1 + $#2 + 1))
    FIRSTLINETABSNO=$(( $TABSNO - $REALNAMESIZE / 8 ))
    FIRSTLINETABS=$(printf '\t%.0s' {1..${FIRSTLINETABSNO}})
    AVAILABLECOL=$((COLUMNS - ${#LINEBREAK}))
    DESC=$(printf "${TABS}$3\n" | fmt -w ${AVAILABLECOL})
    DESC=${DESC:$TABSNO}
    DESC=$(echo ${DESC} | sed "s/${TABS}/${TABS}${LINEBREAK}/g")
    printf "${NAME}${FIRSTLINETABS}${DESC}\n\n"
}

chelp() {
    printf "\nComandos para rodar programas em C/C++! 💻\n\n"
    printcommand 'cnew' '[nome do arquivo]' "gera um novo arquivo C na pasta atual, com um template inicial."
    printcommand 'crun' '[nome do arquivo.c]' "compila e roda um código em C (use \\${TTYBOLD}TAB\\${TTYRESET} para completar o nome do arquivo ao escrever na linha de comando)."
    printcommand 'cppnew' '[nome do arquivo]' "gera um novo arquivo C++ na pasta atual, com um template inicial."
    printcommand 'cpprun' '[nome do arquivo.cpp]' "compila e roda um código em C++ (use \\${TTYBOLD}TAB\\${TTYRESET} para completar o nome do arquivo ao escrever na linha de comando)."
    printcommand 'out' '' "roda o último código em C/C++ compilado com \\${LIGHTBLUE}crun\\${NOCOLOR} ou \\${LIGHTBLUE}cpprun\\${NOCOLOR} na pasta atual."
    printcommand 'ctempl' '[nome do arquivo.c]' "redefine o template inicial para arquivos C."
    printcommand 'cpptempl' '[nome do arquivo.cpp]' "redefine o template inicial para arquivos C++."
    printcommand 'hidevscc' '' "caso esteja usando VS Code, este comando torna invisíveis os arquivos de compilação para não poluir a área de trabalho."
    printf "${TTYBOLD}Better C/C++ Tools v${BETTERCCPPVERS}${TTYRESET} - feito por ${LIGHTBLUE}@henriquefalconer${NOCOLOR} (https://github.com/henriquefalconer)\n\n"
    printf "Sugestões ou problemas podem ser submetidos aqui: ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues${TTYRESET}\n\n"
}

# ------ End of Better C/C++ Tools ------
