
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

# Obtém o valor que corresponde com a chave passada do JSON de informações da última versão do projeto.
getlatestversiondata() {
    printf -- "$(awk "/^  \"$1\": .+/{print}" <(printf "%s\n" "$CCPPRELEASES") | sed -e "s/^  \"$1\": \"\{0,1\}//g" -e "s/\"\{0,1\},\{0,1\}$//g")"
}

# Realiza o curl para obter o JSON das informações da última versão do projeto.
crefreshversions() {
    SECONDSSINCELASTRUN=$(($(date +%s) - LASTTIMECREFRESHRUN))
    if [[ "$SECONDSSINCELASTRUN" -gt 3600 || $1 == 'force' ]]; then
        LASTTIMECREFRESHRUN=$(date +%s)
        CCPPRELEASES=$(curl -s 'https://api.github.com/repos/henriquefalconer/better-c-cpp-tools/releases/latest')
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

readinput() {
    printf "$1 $TTYBOLD"
    read $2
    printf "$TTYRESET"
}

yesorno() {
    readinput "$1 (Y/n)" USERRESPONSE
    if [[ ! "$USERRESPONSE" =~ ^'[yY]{0,1}'$ ]]; then
        return 1
    fi
}

checkoverwrite() {
    printf '\n'
    for file in $@; do
        if [ -f $file ]; then
            if ! yesorno "O arquivo ${LIGHTBLUE}$file${NOCOLOR} já existe. Você gostaria de sobrescrevê-lo?"; then
                printf '\n'
                return 1
            fi
            printf '\n'
        fi
    done
}

alias out='printfeval ./.a.out'

crun() {
    printfeval "gcc -ansi -pedantic -Wall -fexceptions -g -o .a.out $1" && out
    ccheckupdate
}

cnew() {
    if checkoverwrite $1.c; then
        cp ~/.template.c $1.c
        printf "Arquivo ${LIGHTBLUE}$1.c${NOCOLOR} criado na sua pasta!\n\n"
    fi
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
    if checkoverwrite $1.cpp; then
        cp ~/.template.cpp $1.cpp
        printf "Arquivo ${LIGHTBLUE}$1.cpp${NOCOLOR} criado na sua pasta!\n\n"
    fi
}

cppclass() {
    if [ -z $1 ]; then
        printf "\nVocê deve passar o nome da classe como parâmetro.\n\n"
        return 1
    fi
    printf "\nCriando a classe ${TTYBOLD}$1$TTYRESET! 🏭\n\n"
    HIMPORTS=''
    HLOCALIMPORTS=''
    HDEFINITIONS=''
    HATTRS=''
    HGETTERS=''
    HSETTERS=''
    HMETHODS=''
    CONSTRUCTORCOMMA=''
    CONSTRUCTORPARAMS=''
    CPPCONSTRUCTORBODY=''
    HDESTRUCTOR=''
    CPPDESTRUCTOR=''
    CPPGETTERS=''
    CPPSETTERS=''
    CPPMETHODS=''
    printf -- "---- 1/3 ${TTYBOLD}ATRIBUTOS$TTYRESET 🍿 ----\n"
    while true; do
        readinput "\nNome (ou ${TTYBOLD}ENTER$TTYRESET para pular):" ATTRNAME
        [ "$ATTRNAME" = '' ] && break
        ATTRVALUE=''
        ATTRNAMEAPPEND=''
        ATTRNAMEPREPEND=''
        if [[ $ATTRNAME =~ .*' *= *'.* ]]; then
            ATTRVALUE=" = $(printf "$ATTRNAME" | sed -e "s/.*= *//g")"
            ATTRNAME=$(printf "$ATTRNAME" | sed -e "s/ *=.*//g")
        fi
        readinput "\nTipo (string, int, int[10] etc.):" ATTRTYPE
        if [[ $ATTRTYPE =~ .*'string'.* && ! $HIMPORTS =~ .*'#include <string>'.* ]]; then
            HIMPORTS="$HIMPORTS\n#include <string>\nusing namespace std;"
        elif [[ $ATTRTYPE =~ .*'\[.*\]'.* ]]; then
            ATTRMAXLENGTH=$(printf "$ATTRTYPE" | sed -e "s/.*\[//g" -e "s/\]//g")
            ATTRTYPE=$(printf "$ATTRTYPE" | sed -e "s/\[.*\]//g")
            UPPERCASE=$(printf "$ATTRNAME" | tr '[:lower:]' '[:upper:]')
            HDEFINITIONS="$HDEFINITIONS\n#define MAXIMO_$UPPERCASE $ATTRMAXLENGTH"
            ATTRNAMEAPPEND="[MAXIMO_${UPPERCASE}]"
            ATTRNAMEPREPEND="*"
        fi
        if [[ $ATTRTYPE =~ ^[A-Z] ]]; then
            HLOCALIMPORT=$(printf "$ATTRTYPE" | sed -e "s/\*//g")
            [[ ! $HLOCALIMPORT = $1 && ! $HLOCALIMPORTS =~ .*"$HLOCALIMPORT".* ]] && HLOCALIMPORTS="$HLOCALIMPORTS\n#include \"$HLOCALIMPORT.h\"\nclass $HLOCALIMPORT;"
        fi
        CAPITALIZED=$(perl -lne 'use open qw(:std :utf8); print ucfirst' <<<$ATTRNAME)
        if [[ ! $ATTRTYPE =~ ^'const ' ]]; then
            CONSTRUCTORPARAMS="${CONSTRUCTORPARAMS}${CONSTRUCTORCOMMA}${ATTRTYPE}$ATTRNAMEPREPEND ${ATTRNAME}"
            CONSTRUCTORCOMMA=', '
            ATTRSETTER="${ATTRNAMEPREPEND}this->$ATTRNAME = ${ATTRNAMEPREPEND}$ATTRNAME;"
            CPPCONSTRUCTORBODY="$CPPCONSTRUCTORBODY\n    ${ATTRSETTER}"
            ATTRSETTERPARAM="set$CAPITALIZED($ATTRTYPE${ATTRNAMEPREPEND} $ATTRNAME)"
            HSETTERS="$HSETTERS\n    void ${ATTRSETTERPARAM};"
            CPPSETTERS="${CPPSETTERS}void $1::${ATTRSETTERPARAM} { ${ATTRSETTER} }\n\n"
        fi
        HATTRS="$HATTRS\n    $ATTRTYPE ${ATTRNAME}${ATTRNAMEAPPEND}$ATTRVALUE;"
        HGETTERS="$HGETTERS\n    ${ATTRTYPE}$ATTRNAMEPREPEND get$CAPITALIZED();"
        CPPGETTERS="${CPPGETTERS}${ATTRTYPE}$ATTRNAMEPREPEND $1::get$CAPITALIZED() { return this->$ATTRNAME; }\n\n"
    done
    printf "\n----- 2/3 ${TTYBOLD}MÉTODOS$TTYRESET 🔧 -----\n"
    while true; do
        readinput "\nNome (ou ${TTYBOLD}ENTER$TTYRESET para pular):" METHODNAME
        [ "$METHODNAME" = '' ] && break
        readinput "\nTipo de retorno (int, void etc.):" METHODTYPE
        readinput "\nLista de parâmetros (ex.: \"string nome, int contatos[]\"):" METHODPARAMS
        if [[ ($METHODTYPE =~ .*'string'.* || $METHODPARAMS =~ .*'string'.*) && ! $HIMPORTS =~ .*'#include <string>'.* ]]; then
            HIMPORTS="$HIMPORTS\n#include <string>\nusing namespace std;"
        fi
        # TODO: adicionar local import se existir em METHODPARAMS
        if [[ $METHODTYPE =~ ^[A-Z] ]]; then
            HLOCALIMPORT=$(printf "$METHODTYPE" | sed -e "s/\*//g")
            [[ ! $HLOCALIMPORT = $1 && ! $HLOCALIMPORTS =~ .*"$HLOCALIMPORT".* ]] && HLOCALIMPORTS="$HLOCALIMPORTS\n#include \"$HLOCALIMPORT.h\"\nclass $HLOCALIMPORT;"
        fi
        HMETHODS="$HMETHODS\n    $METHODTYPE $METHODNAME($METHODPARAMS);"
        CPPMETHODS="${CPPMETHODS}$METHODTYPE $1::$METHODNAME($METHODPARAMS) {\n    // TODO: adicionar código\n}\n\n"
    done
    printf "\n----- 3/3 ${TTYBOLD}CONFIGURAÇÕES$TTYRESET 🔧 -----\n"
    if yesorno "\nIncluir um destrutor?"; then
        HDESTRUCTOR="~$1();"
        CPPDESTRUCTOR="$1::~$1() {\n    // TODO: adicionar lógica de liberação de memória\n}"
    fi
    formatmultilinetr() {
        [ -z "$1" ] || printf "$2$1"
    }
    HIMPORTS=$(formatmultilinetr "$HIMPORTS" '\n')
    HLOCALIMPORTS=$(formatmultilinetr "$HLOCALIMPORTS" '\n')
    HDEFINITIONS=$(formatmultilinetr "$HDEFINITIONS" '\n')
    HATTRS=$(formatmultilinetr "$HATTRS")
    HCONSTRUCTOR=$(formatmultilinetr "$1($CONSTRUCTORPARAMS);" '\n    ')
    HDESTRUCTOR=$(formatmultilinetr "$HDESTRUCTOR" '\n    ')
    HGETTERS=$(formatmultilinetr "$HGETTERS" '\n    // Getters')
    HSETTERS=$(formatmultilinetr "$HSETTERS" '\n    // Setters')
    HMETHODS=$(formatmultilinetr "$HMETHODS" '\n    // Methods')
    CPPCONSTRUCTOR=$(formatmultilinetr "$1::$1($CONSTRUCTORPARAMS) {${CPPCONSTRUCTORBODY}\n}" '\n\n')
    CPPDESTRUCTOR=$(formatmultilinetr "$CPPDESTRUCTOR" '\n\n')
    CPPGETTERS=$(formatmultilinetr "$CPPGETTERS" '\n\n// Getters\n')
    CPPSETTERS=$(formatmultilinetr "$CPPSETTERS" '\n\n// Setters\n')
    CPPMETHODS=$(formatmultilinetr "$CPPMETHODS" '\n\n// Methods\n')
    UPPERCASE=$(printf "$1" | tr '[:lower:]' '[:upper:]')
    if checkoverwrite $1.h $1.cpp; then
        cat >$1.h <<-END
			#ifndef ${UPPERCASE}_H
			#define ${UPPERCASE}_H${HIMPORTS}${HLOCALIMPORTS}${HDEFINITIONS}
			
			class $1 {
			   private:${HATTRS}
			
			   public:${HCONSTRUCTOR}${HDESTRUCTOR}${HGETTERS}${HSETTERS}${HMETHODS}
			};
			
			#endif  // ${UPPERCASE}_H
		END
        cat >$1.cpp <<-END
			#include "$1.h"${CPPCONSTRUCTOR}${CPPDESTRUCTOR}${CPPGETTERS}${CPPSETTERS}${CPPMETHODS}
		END
        printf "Arquivos ${LIGHTBLUE}$1.h$NOCOLOR e ${LIGHTBLUE}$1.cpp$NOCOLOR criados na sua pasta! 🚀\n\n"
    fi
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
		        "**/.a.out.dSYM": true,
		        "**/.a.out": true
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
    if [[ $OS == 'Linux' ]]; then
        find . -regex ".*\.\(cpp\|h\)" -print | zip files -@
    else
        find -E . -iregex ".*\.(cpp|h)" -print | zip files -@
    fi
    commentm $1 files
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
    if yesorno "\nNovidades do Better C/C++ Tools v$LATESTVERSIONNAME 🚀\n\n$LATESTVERSIONDESC\n\n${TTYBOLD}Obs.:${TTYRESET} a descrição de todas as versões está disponível em ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/releases${TTYRESET}\n\nVocê gostaria de baixar esta versão?"; then
        printf "\n🔎  Baixando mais nova versão das funções e templates..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/install.sh)" >/dev/null 2>&1
        printf " Feito!\n\n"
        printf "ℹ️   Para utilizar a nova versão, feche este shell e abra-o novamente.\n\n"
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
    printcommand 'cppclass' '[nome da classe]' "gera um par de arquivos .h e .cpp na pasta atual, a partir das informações dadas na linha de comando, além de automaticamente criar setters e getters para todos os atributos. \\$GREEN(Novo!)\\$NOCOLOR"
    printcommand 'cpprun' '[nome do arquivo.cpp]' "compila e roda um código em C++ (use \\${TTYBOLD}TAB\\$TTYRESET para completar o nome do arquivo ao escrever na linha de comando)."
    printcommand 'out' '' "roda o último código em C/C++ compilado com \\${LIGHTBLUE}crun\\$NOCOLOR ou \\${LIGHTBLUE}cpprun\\$NOCOLOR na pasta atual."
    printcommand 'ctempl' '[nome do arquivo.c]' 'redefine o template inicial para arquivos C.'
    printcommand 'cpptempl' '[nome do arquivo.cpp]' 'redefine o template inicial para arquivos C++.'
    printcommand 'cppzip' '[nome do arquivo.cpp]' "comenta o main do arquivo passado e cria \\${TTYBOLD}files.zip\\$TTYRESET com todos os arquivos .h e .cpp da pasta. \\${TTYBOLD}IMPORTANTE:\\$TTYRESET deve ser rodado na mesma pasta do arquivo passado como parâmetro."
    printcommand 'hidevscc' '' 'caso esteja usando VS Code, este comando torna invisíveis os arquivos de compilação para não poluir a área de trabalho.'
    printcommand 'cupdate' '' "baixa e atualiza o \\${TTYBOLD}Better C/C++ Tools\\$TTYRESET para a última versão disponível."
    printf "${TTYBOLD}Better C/C++ Tools v${BETTERCCPPVERS}$TTYRESET - feito por $LIGHTBLUE@henriquefalconer$NOCOLOR (https://github.com/henriquefalconer)\n\n"
    printf "Sugestões ou problemas podem ser submetidos aqui: ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues$TTYRESET\n"
    ccheckupdate
}

# ------ End of Better C/C++ Tools ------
