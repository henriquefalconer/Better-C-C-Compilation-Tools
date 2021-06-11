
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
FINALLINEBREAK='\n'
SUCCESS='🚀'
ROCKET='🚀'
FACTORY='🏭'
POPCORN='🍿 '
WRENCH='🔧 '
SEARCHI='🔎  '
INFOI='ℹ️  '
COMPUTER='💻'

# Se o sistema for Linux ou Windows, remover caractere unicode.
OS=$(uname)
if [[ $OS != 'Darwin' ]]; then
    LINEBREAK=''
fi

# Se o sistema for Windows, utilizar emojis compatíveis e remover quebra de linha final.
if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
    FINALLINEBREAK=''
    SUCCESS='✔️'
    ROCKET=''
    FACTORY=''
    POPCORN=''
    WRENCH=''
    SEARCHI=''
    INFOI='❕ '
    COMPUTER=''
fi

finalprint() {
    printf "$FINALLINEBREAK"
}

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
        if regexmatch "$CCPPRELEASES" ".*API rate limit exceeded.*"; then
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
            printf "\n${TTYBOLD}Better C/C++ Tools v${LATESTVERSIONNAME}$TTYRESET já está disponível! Rode ${LIGHTBLUE}cupdate$1$NOCOLOR para visualizar as novas funcionalidades $ROCKET\n"
            finalprint
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

# Permite utilizar regex no Git Bash do Windows (ele não aceita o =~).
regexmatch() {
    if ! printf "$1" | grep -E "$2" >> /dev/null; then
        return 1
    fi
}

yesorno() {
    readinput "$1 (Y/n)" USERRESPONSE
    if regexmatch "$USERRESPONSE" '^[^yY]{0,1}$'; then
        return 1
    fi
}

checkoverwrite() {
    printf '\n'
    for file in $@; do
        if [ -f $file ] || [ -d $file ]; then
            if ! yesorno "O $([ -d $file ] && printf "diretório" || printf "arquivo") ${LIGHTBLUE}$file${NOCOLOR} já existe. Você gostaria de $([ -d $file ] && printf "sobrescrever os arquivos dentro dele" || printf "sobrescrevê-lo")?"; then
                printf '\n'
                return 1
            fi
            printf '\n'
        fi
    done
}

checkparam() {
    if [ -z $1 ]; then
        printf "\n$2\n"
        finalprint
        return 0
    fi
    return 1
}

alias out='printfeval ./.a.out'

crun() {
    printfeval "gcc -ansi -pedantic -Wall -fexceptions -g -o .a.out $1" && out
    ccheckupdate
}

cnew() {
    if checkparam "$1" "Você deve passar o nome do arquivo como parâmetro."; then
        return 1
    fi
    if checkoverwrite $1.c; then
        cp ~/.ccpptemplates/template.c $1.c
        printf "Arquivo ${LIGHTBLUE}$1.c${NOCOLOR} criado na sua pasta! $SUCCESS\n"
        printf "Para testá-lo, rode ${LIGHTBLUE}crun $1.c${NOCOLOR}\n"
        finalprint
    fi
}

ctempl() {
    if checkparam "$1" "Você deve passar o nome do arquivo como parâmetro."; then
        return 1
    fi
    cp $1 ~/.ccpptemplates/template.c
    printf "\nConteúdo do arquivo ${LIGHTBLUE}$1${NOCOLOR} definido como o novo template de C! $SUCCESS\n"
    finalprint
}

alias cpprun="printfeval \"g++ -std=c++11 *.cpp -o .a.out\" && out && ccheckupdate"

cppnew() {
    if checkparam "$1" "Você deve passar o nome do projeto como parâmetro."; then
        return 1
    fi
    local createproject() {
        if checkoverwrite $1; then
            rm -rf $1
            cp -r $2 $1
            printf "O projeto ${LIGHTBLUE}$1${NOCOLOR} foi criado na sua pasta! $SUCCESS\n"
            printf "Para acessá-lo, rode ${LIGHTBLUE}cd $1${NOCOLOR} e, para testá-lo, rode ${LIGHTBLUE}cpprun${NOCOLOR}\n"
            finalprint
        fi
    }
    if yesorno "\nIncluir ${LIGHTBLUE}iofuncs${NOCOLOR}?"; then
        createproject $1 ~/.ccpptemplates/cpp/withio
    else
        createproject $1 ~/.ccpptemplates/cpp/raw
    fi
}

cppclass() {
    if checkparam "$1" "Você deve passar o nome da classe como parâmetro."; then
        return 1
    fi
    printf "\nCriando a classe ${TTYBOLD}$1$TTYRESET! $FACTORY\n\n"
    HIMPORTS=''
    HLOCALIMPORTS=''
    HDEFINITIONS=''
    HATTRS=''
    HGETTERS=''
    HSETTERS=''
    HMETHODS=''
    CONSTRUCTORCOMMA=''
    CONSTRUCTORPARAMS=''
    CPPCONSTRUCTORATTRIBUTION=''
    HDESTRUCTOR=''
    CPPDESTRUCTOR=''
    CPPGETTERS=''
    CPPSETTERS=''
    CPPMETHODS=''
    printf -- "---- 1/3 ${TTYBOLD}ATRIBUTOS$TTYRESET $POPCORN----\n"
    while true; do
        readinput "\nNome (ou ${TTYBOLD}ENTER$TTYRESET para pular):" ATTRNAME
        [ "$ATTRNAME" = '' ] && break
        ATTRVALUE=''
        ATTRNAMEAPPEND=''
        ATTRNAMEPREPEND=''
        if regexmatch "$ATTRNAME" '.* *= *.*'; then
            ATTRVALUE=" = $(printf "$ATTRNAME" | sed -e "s/.*= *//g")"
            ATTRNAME=$(printf "$ATTRNAME" | sed -e "s/ *=.*//g")
        fi
        readinput "\nTipo (string, int, int[10] etc.):" ATTRTYPE
        if regexmatch "$ATTRTYPE" '.*string.*' && ! regexmatch "$HIMPORTS" '.*#include <string>.*'; then
            HIMPORTS="$HIMPORTS\n#include <string>\nusing namespace std;"
        elif regexmatch "$ATTRTYPE" '.*\[.*\].*'; then
            ATTRMAXLENGTH=$(printf "$ATTRTYPE" | sed -e "s/.*\[//g" -e "s/\]//g")
            ATTRTYPE=$(printf "$ATTRTYPE" | sed -e "s/\[.*\]//g")
            UPPERCASE=$(printf "$ATTRNAME" | tr '[:lower:]' '[:upper:]')
            HDEFINITIONS="$HDEFINITIONS\n#define MAXIMO_$UPPERCASE $ATTRMAXLENGTH"
            ATTRNAMEAPPEND="[MAXIMO_${UPPERCASE}]"
            ATTRNAMEPREPEND="*"
        fi
        if regexmatch "$ATTRTYPE" '^[A-Z]'; then
            HLOCALIMPORT=$(printf "$ATTRTYPE" | sed -e "s/\*//g")
            [[ ! $HLOCALIMPORT = $1 ]] && ! regexmatch "$HLOCALIMPORTS" ".*$HLOCALIMPORT.*" && HLOCALIMPORTS="$HLOCALIMPORTS\n#include \"$HLOCALIMPORT.h\"\nclass $HLOCALIMPORT;"
        fi
        CAPITALIZED=$(perl -lne 'use open qw(:std :utf8); print ucfirst' <<<$ATTRNAME)
        if ! regexmatch "$ATTRTYPE" '^const ' && [ -z "$ATTRNAMEPREPEND" ]; then
            CONSTRUCTORPARAMS="${CONSTRUCTORPARAMS}${CONSTRUCTORCOMMA}${ATTRTYPE}$ATTRNAMEPREPEND ${ATTRNAME}"
            CONSTRUCTORCOMMA=', '
            CPPCONSTRUCTORATTRIBUTION="$CPPCONSTRUCTORATTRIBUTION\n    $ATTRNAME($ATTRNAME)"
            ATTRSETTERPARAM="set$CAPITALIZED($ATTRTYPE $ATTRNAME)"
            HSETTERS="$HSETTERS\n    void ${ATTRSETTERPARAM};"
            CPPSETTERS="${CPPSETTERS}void $1::${ATTRSETTERPARAM} { this->$ATTRNAME = $ATTRNAME; }\n\n"
        fi
        HATTRS="$HATTRS\n    $ATTRTYPE ${ATTRNAME}${ATTRNAMEAPPEND}$ATTRVALUE;"
        HGETTERS="$HGETTERS\n    ${ATTRTYPE}$ATTRNAMEPREPEND get$CAPITALIZED();"
        CPPGETTERS="${CPPGETTERS}${ATTRTYPE}$ATTRNAMEPREPEND $1::get$CAPITALIZED() { return this->$ATTRNAME; }\n\n"
    done
    printf "\n----- 2/3 ${TTYBOLD}MÉTODOS$TTYRESET $WRENCH-----\n"
    while true; do
        readinput "\nNome (ou ${TTYBOLD}ENTER$TTYRESET para pular):" METHODNAME
        [ "$METHODNAME" = '' ] && break
        readinput "\nTipo de retorno (int, void etc.):" METHODTYPE
        readinput "\nLista de parâmetros (ex.: \"string nome, int contatos[]\"):" METHODPARAMS
        if (regexmatch "$METHODTYPE" '.*string.*' || regexmatch "$METHODPARAMS" '.*string.*') && ! regexmatch "$HIMPORTS" '.*#include <string>.*'; then
            HIMPORTS="$HIMPORTS\n#include <string>\nusing namespace std;"
        fi
        # TODO: adicionar local import se existir em METHODPARAMS
        if regexmatch "$METHODTYPE" '^[A-Z]'; then
            HLOCALIMPORT=$(printf "$METHODTYPE" | sed -e "s/\*//g")
            [[ ! $HLOCALIMPORT = $1 ]] && ! regexmatch "$HLOCALIMPORTS" ".*$HLOCALIMPORT.*" && HLOCALIMPORTS="$HLOCALIMPORTS\n#include \"$HLOCALIMPORT.h\"\nclass $HLOCALIMPORT;"
        fi
        HMETHODS="$HMETHODS\n    $METHODTYPE $METHODNAME($METHODPARAMS);"
        CPPMETHODS="${CPPMETHODS}$METHODTYPE $1::$METHODNAME($METHODPARAMS) {\n    // TODO: adicionar código\n}\n\n"
    done
    printf "\n----- 3/3 ${TTYBOLD}CONFIGURAÇÕES$TTYRESET $WRENCH-----\n"
    if yesorno "\nIncluir um destrutor?"; then
        HDESTRUCTOR="virtual ~$1();"
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
    CPPCONSTRUCTORATTRIBUTION=$(formatmultilinetr "$CPPCONSTRUCTORATTRIBUTION" ':\n    ')
    CPPCONSTRUCTOR=$(formatmultilinetr "$1::$1($CONSTRUCTORPARAMS)$CPPCONSTRUCTORATTRIBUTION {}" '\n\n')
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
        printf "Arquivos ${LIGHTBLUE}$1.h$NOCOLOR e ${LIGHTBLUE}$1.cpp$NOCOLOR criados na sua pasta! $SUCCESS\n"
        finalprint
    fi
}

hidevscc() {
    mkdir -p .vscode
    cat >.vscode/settings.json <<-END
		{
		    "files.exclude": {
		        "**/.a.out.dSYM": true,
		        "**/.a.out": true
		    }
		}
	END
    printf "\n${LIGHTBLUE}.vscode/settings.json${NOCOLOR} configurado! $SUCCESS\n"
    finalprint
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
    if yesorno "\nNovidades do Better C/C++ Tools v$LATESTVERSIONNAME $ROCKET\n\n$LATESTVERSIONDESC\n\n${TTYBOLD}Obs.:${TTYRESET} a descrição de todas as versões está disponível em ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/releases${TTYRESET}\n\nVocê gostaria de baixar esta versão?"; then
        printf "\n${SEARCHI}Baixando mais nova versão das funções e templates..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/install.sh)" >/dev/null 2>&1
        printf " Feito!\n\n"
        printf "${INFOI}Para utilizar a nova versão, feche este shell e abra-o novamente.\n"
        finalprint
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
    printf "\nComandos para rodar programas em C/C++! $COMPUTER\n\n"
    printcommand 'cnew' '[nome do arquivo]' 'gera um novo arquivo C na pasta atual, com um template inicial.'
    printcommand 'crun' '[nome do arquivo.c]' "compila e roda um código em C (use \\${TTYBOLD}TAB\\$TTYRESET para completar o nome do arquivo ao escrever na linha de comando)."
    printcommand 'cppnew' '[nome do projeto]' 'gera um novo projeto de C++ na pasta atual, com um template inicial.'
    printcommand 'cppclass' '[nome da classe]' "gera um par de arquivos .h e .cpp na pasta atual, a partir das informações dadas na linha de comando, além de automaticamente criar setters e getters para todos os atributos. \\$GREEN(Novo!)\\$NOCOLOR"
    printcommand 'cpprun' '' "compila todos os arquivos C++ da pasta atual, rodando a função main. Deve ser rodado na pasta do projeto. \\${TTYBOLD}IMPORTANTE:\\$TTYRESET se a pasta atual possuir mais de um projeto, ocorrerá um erro."
    printcommand 'out' '' "roda o último código em C/C++ compilado com \\${LIGHTBLUE}crun\\$NOCOLOR ou \\${LIGHTBLUE}cpprun\\$NOCOLOR na pasta atual."
    printcommand 'ctempl' '[nome do arquivo.c]' 'redefine o template inicial para arquivos C.'
    printcommand 'cppzip' '[nome do arquivo.cpp]' "comenta o main do arquivo passado e cria \\${TTYBOLD}files.zip\\$TTYRESET com todos os arquivos .h e .cpp da pasta. \\${TTYBOLD}IMPORTANTE:\\$TTYRESET deve ser rodado na mesma pasta do arquivo passado como parâmetro."
    printcommand 'hidevscc' '' 'caso esteja usando VS Code, este comando torna invisíveis os arquivos de compilação para não poluir a área de trabalho.'
    printcommand 'cupdate' '' "baixa e atualiza o \\${TTYBOLD}Better C/C++ Tools\\$TTYRESET para a última versão disponível."
    printf "${TTYBOLD}Better C/C++ Tools v${BETTERCCPPVERS}$TTYRESET - feito por $LIGHTBLUE@henriquefalconer$NOCOLOR (https://github.com/henriquefalconer)\n\n"
    printf "Sugestões ou problemas podem ser submetidos aqui: ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues$TTYRESET\n"
    ccheckupdate
}

# ------ End of Better C/C++ Tools ------
