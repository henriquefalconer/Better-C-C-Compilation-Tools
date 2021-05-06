
# ------ Start of Better C/C++ Tools ------

BETTERCCPPVERS='X.X.X'

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

# A partir das releases do projeto, obtém o valor que corresponde com a chave passada da última versão.
getlatestversiondata() {
    printf "$(awk "/^    \"$1\": .+/{print}" <(printf "%s\n" "$CCPPRELEASES") | head -1 | sed -e "s/^    \"$1\": \"\{0,1\}//g" -e "s/\"\{0,1\},\{0,1\}$//g")"
}

# Realiza o curl para obter as releases, caso esteja instalando pela primeira vez.
crefreshversions() {
    SECONDSSINCELASTRUN=$(($(date +%s) - LASTTIMECREFRESHRUN))
    if [[ "$SECONDSSINCELASTRUN" -gt 3600 || $1 == 'force' ]]; then
        LASTTIMECREFRESHRUN=$(date +%s)
        CCPPRELEASES=$(curl -s 'https://api.github.com/repos/henriquefalconer/better-c-cpp-tools/releases')
        if [[ $CCPPRELEASES =~ .*"API rate limit exceeded".* ]]; then
            printf "\nA API do GitHub restringiu seu acesso às versões do projeto. Adicione um tópico em ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues${TTYRESET} caso isso ocorra repetidamente.\n\n"
            CREFRESHFAILED=true
        else
            LATESTVERSIONNAME=$(getlatestversiondata name)
            CREFRESHFAILED=false
        fi
    fi
}

ccheckupdate() {
    crefreshversions
    if [ $CREFRESHFAILED = false ]; then
        if [ "$LATESTVERSIONNAME" != "$BETTERCCPPVERS" ]; then
            printf "\n${TTYBOLD}Better C/C++ Tools v${LATESTVERSIONNAME}$TTYRESET já está disponível! Rode ${LIGHTBLUE}cupdate$1$NOCOLOR para visualizar as novas funcionalidades 🚀\n\n"
        fi
    fi
}

printfeval() {
    printf "$PURPLE$ $1$NOCOLOR\n"
    eval $1
}

alias out='printfeval ./.a.out'

crun() {
    printfeval "gcc -ansi -pedantic -Wall -fexceptions -g -o .a.out $1" && out
    ccheckupdate
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
    ccheckupdate
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
    mkdir -p .vscode
    cat >.vscode/settings.json <<-END
		{
		    "files.exclude": {
		        ".a.out.dSYM": true,
		        ".a.out": true
		    }
		}
	END
}

cupdate() {
    crefreshversions force

    if [ $CREFRESHFAILED = true ]; then
        return 1
    fi
    
    if [ "$LATESTVERSIONNAME" = "$BETTERCCPPVERS" ]; then
        printf "\nVocê já possui a versão mais recente do Better C/C++ Tools.\n\n"
        return 1
    fi

    LATESTVERSIONDESC=$(getlatestversiondata body | sed -e "s/\`/\` /g" -e "s/ \` / \\$LIGHTBLUE/g" -e "s/\` /\\$NOCOLOR/g")
    printf "\nNovidades do Better C/C++ Tools v$LATESTVERSIONNAME 🚀\n\n$LATESTVERSIONDESC\n\nVocê gostaria de baixar esta versão? (Y/n) "
    read USERRESPONSE

    if [[ "$USERRESPONSE" == 'Y' || "$USERRESPONSE" == 'y' || "$USERRESPONSE" == '' ]]; then
        printf "\n🔎  Baixando mais nova versão das funções e templates..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/install.sh)" >/dev/null 2>&1
        printf " Feito!\n\n"
        # Verifica se os comandos foram carregados com o "source".
        if [ "$LATESTVERSIONNAME" != "$BETTERCCPPVERS" ]; then
            printf "\n\nPara utilizar a nova versão, feche este shell e abra-o novamente.\n\n"
        fi
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
    printcommand 'hidevscc' '' 'caso esteja usando VS Code, este comando torna invisíveis os arquivos de compilação para não poluir a área de trabalho.'
    printcommand 'cupdate' '' "baixa e atualiza o \\${TTYBOLD}Better C/C++ Tools\\$TTYRESET para a última versão disponível."
    printf "${TTYBOLD}Better C/C++ Tools v${BETTERCCPPVERS}$TTYRESET - feito por $LIGHTBLUE@henriquefalconer$NOCOLOR (https://github.com/henriquefalconer)\n\n"
    printf "Sugestões ou problemas podem ser submetidos aqui: ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues$TTYRESET\n"
    ccheckupdate
}

# ------ End of Better C/C++ Tools ------
