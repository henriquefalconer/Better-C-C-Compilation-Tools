
# ------ Start of Better C/C++ Tools ------

BETTERCCPPVERS='1.0'

# Formatação de strings
LIGHTBLUE='\e[94m'
PURPLE='\e[0;35m'
GREEN='\e[32m'
RED='\e[31m'
NOCOLOR='\e[0m'
TTYBOLD='\033[1;39m'
TTYRESET='\033[1;0m'
LINEBREAK='⮑  '

# Se o sistema for Linux, remover caractere unicode.
OS=$(uname)
if [[ $OS == 'Linux' ]]; then
    LINEBREAK=''
fi

printfeval() {
    printf "$PURPLE$ $1$NOCOLOR\n"
    eval $1
}

alias out='printfeval ./.a.out'

crun() {
    printfeval "gcc -ansi -pedantic -Wall -fexceptions -g -o .a.out $1" && out
}

cnew() {
    cp ~/.template.c $1.c
}

ctempl() {
    cp $1 ~/.template.c
    printf "\nConteúdo do arquivo ${LIGHTBLUE}$1${NOCOLOR} definido como o novo template de C! 🚀\n\n"
}

cpprun() {
    printfeval "g++ -std=c++11 -pedantic -Wall -fexceptions -g -o .a.out $1" && out
}

cppnew() {
    cp ~/.template.cpp $1.cpp
}

cpptempl() {
    cp $1 ~/.template.cpp
    printf "\nConteúdo do arquivo ${LIGHTBLUE}$1${NOCOLOR} definido como o novo template de C++! 🚀\n\n"
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

commentm() {
    awk '!/^\/\*$|^\*\/$/' $1 | awk '/int main()/{ print "/*" } END{ print "*/" } 1' >tmp
    cp $1 $1.tmp
    cp tmp $1
    zip $2 $1
    cp $1.tmp $1
    rm tmp $1.tmp
}

cppzip() {
    commentm $1 files

    if [[ $OS == 'Linux' ]]; then
        find . -regex ".*\.\(cpp\|h\)" -print | zip files -@
    else
        find -E . -iregex ".*\.(cpp|h)" -print | zip files -@
    fi
}

cupdate() {
    printf "\n🔎  Baixando mais nova versão das funções e templates..."
    # TODO: implementar verificação da atualização, utilizando a variável BETTERCCPPVERS
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/install.sh)" >/dev/null 2>&1
    # Verifica se os comandos foram carregados com o "source".
    if ! command -v chelp &>/dev/null; then
        printf " ${RED}Erro${NOCOLOR}\n\n"
    else
        printf " Feito!\n\n"
    fi
}

printcommand() {
    # Nome do comando e seus argumentos.
    NAME="${GREEN}$1 ${LIGHTBLUE}$2${NOCOLOR}"
    # Indentação das descrições.
    TABSNO=4
    FAKETAB="        "
    FAKETABS=$(printf "$FAKETAB%.0s" $(seq 1 $TABSNO))
    REALNAMESIZE=$((${#1} + ${#2} + 1))
    # Quantidade de caracteres por linha que o fmt deveria imprimir.
    AVAILABLECOL=$((COLUMNS - ${#FAKETABS} - ${#LINEBREAK}))
    # Formatação da descrição de modo a não ter quebras de linha em palavras.
    DESC=$(printf "\n$3" | fmt -w $AVAILABLECOL)
    # Remoção da indentação da primeira linha da descrição e
    # prepararação para a junção com o nome e seus argumentos.
    DESC=$(echo "$DESC" | sed -e ':a' -e 'N' -e '$!ba' -e "s/\n/\n$FAKETABS/g")
    DESC=${DESC:$REALNAMESIZE+1}
    # Inserção do caractere de quebra de linha em todas as linhas
    # menos a primeira.
    DESC=$(echo "$DESC" | sed "s/$FAKETABS/${FAKETABS}$LINEBREAK/g")
    # Junção com o nome e seus argumentos.
    printf "${NAME}$DESC\n\n"
}

chelp() {
    printf '\nComandos para rodar programas em C/C++! 💻\n\n'
    printcommand 'cnew' '[nome do arquivo]' 'gera um novo arquivo C na pasta atual, com um template inicial.'
    printcommand 'crun' '[nome do arquivo.c]' "compila e roda um código em C (use \\${TTYBOLD}TAB\\$TTYRESET para completar o nome do arquivo ao escrever na linha de comando)."
    printcommand 'cppnew' '[nome do arquivo]' 'gera um novo arquivo C++ na pasta atual, com um template inicial.'
    printcommand 'cpprun' '[nome do arquivo.cpp]' "compila e roda um código em C++ (use \\${TTYBOLD}TAB\\$TTYRESET para completar o nome do arquivo ao escrever na linha de comando)."
    printcommand 'out' '' "roda o último código em C/C++ compilado com \\${LIGHTBLUE}crun\\$NOCOLOR ou \\${LIGHTBLUE}cpprun\\$NOCOLOR na pasta atual."
    printcommand 'ctempl' '[nome do arquivo.c]' 'redefine o template inicial para arquivos C.'
    printcommand 'cpptempl' '[nome do arquivo.cpp]' 'redefine o template inicial para arquivos C++.'
    printcommand 'cppzip' '[nome do arquivo.cpp]' "comenta o main do arquivo passado e cria files.zip com todos os arquivos .h e .cpp da pasta. \\${TTYBOLD}IMPORTANTE:\\$TTYRESET deve ser rodado na mesma pasta do arquivo passado como parâmetro."
    printcommand 'hidevscc' '' 'caso esteja usando VS Code, este comando torna invisíveis os arquivos de compilação para não poluir a área de trabalho.'
    printcommand 'cupdate' '' "baixa e atualiza o \\${TTYBOLD}Better C/C++ Tools\\$TTYRESET para a última versão disponível."
    printf "${TTYBOLD}Better C/C++ Tools v${BETTERCCPPVERS}$TTYRESET - feito por $LIGHTBLUE@henriquefalconer$NOCOLOR (https://github.com/henriquefalconer)\n\n"
    printf "Sugestões ou problemas podem ser submetidos aqui: ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues$TTYRESET\n\n"
}

# ------ End of Better C/C++ Tools ------
