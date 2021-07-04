
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

OS=$(uname)
# Se o sistema for Windows, remover quebra de linha final.
if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
    FINALLINEBREAK=''
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
        if [ -f "$file" ] || [ -d "$file" ]; then
            if ! yesorno "O $([ -d "$file" ] && printf "diretório" || printf "arquivo") ${LIGHTBLUE}$file${NOCOLOR} já existe. Você gostaria de $([ -d "$file" ] && printf "sobrescrever os arquivos dentro dele" || printf "sobrescrevê-lo")?"; then
                printf '\n'
                return 1
            fi
            printf '\n'
        fi
    done
}

checkparam() {
    if [ -z "$1" ]; then
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
    if checkoverwrite "$1.c"; then
        cp "$HOME/.ccpptemplates/template.c" "$1.c"
        printf "Arquivo ${LIGHTBLUE}$1.c${NOCOLOR} criado na sua pasta! $SUCCESS\n"
        printf "Para testá-lo, rode ${LIGHTBLUE}crun $1.c${NOCOLOR}\n"
        finalprint
    fi
}

ctempl() {
    if checkparam "$1" "Você deve passar o nome do arquivo como parâmetro."; then
        return 1
    fi
    cp "$1" "$HOME/.ccpptemplates/template.c"
    printf "\nConteúdo do arquivo ${LIGHTBLUE}$1${NOCOLOR} definido como o novo template de C! $SUCCESS\n"
    finalprint
}

alias cpprun="printfeval \"g++ -std=c++11 *.cpp -o .a.out\" && out && ccheckupdate"

cppnew() {
    if checkparam "$1" "Você deve passar o nome do projeto como parâmetro."; then
        return 1
    fi
    createproject() {
        if checkoverwrite "$1"; then
            rm -rf "$1"
            cp -r "$2" "$1"
            printf "O projeto ${LIGHTBLUE}$1${NOCOLOR} foi criado na sua pasta! $SUCCESS\n"
            printf "Para acessá-lo, rode ${LIGHTBLUE}cd $1${NOCOLOR} e, para testá-lo, rode ${LIGHTBLUE}cpprun${NOCOLOR}\n"
            finalprint
        fi
    }
    if yesorno "\nGostaria de incluir o ${LIGHTBLUE}iofuncs${NOCOLOR}? (funções como print, input etc.)"; then
        createproject "$1" "$HOME/.ccpptemplates/cpp/withio"
    else
        createproject "$1" "$HOME/.ccpptemplates/cpp/raw"
    fi
}

formatmultilinetr() {
    [ -z "$1" ] || printf "$2$1"
}

createhclass() {
    UPPERCASE=$(printf "$1" | tr '[:lower:]' '[:upper:]')
    HPARENTNAMES=$(formatmultilinetr "$HPARENTNAMES" ': ')
    HPRIVATEANDPROTECTED=$(formatmultilinetr "$HPRIVATEANDPROTECTED" '\n')
    HDESTRUCTOR=$(formatmultilinetr "$HDESTRUCTOR" '\n    ')
    HGETTERS=$(formatmultilinetr "$HGETTERS" '\n    // Getters')
    HSETTERS=$(formatmultilinetr "$HSETTERS" '\n    // Setters')
    HMETHODS=$(formatmultilinetr "$HMETHODS" '\n    // Methods')
    [ -z "$HPRIVATEANDPROTECTED" ] && HSPACE='' || HSPACE="\n"
    HPUBLIC=$(formatmultilinetr "${HCONSTRUCTOR}${HDESTRUCTOR}${HGETTERS}${HSETTERS}${HMETHODS}" "$HSPACE\n   public:")
    cat >"$1.h" <<-END
		#ifndef ${UPPERCASE}_H
		#define ${UPPERCASE}_H${HIMPORTSANDDEFINITIONS}
		
		class $1${HPARENTNAMES} {${HPRIVATEANDPROTECTED}${HPUBLIC}
		};
		
		#endif  // ${UPPERCASE}_H
	END
}

createcppclass() {
    CPPSTATICATTRS=$(formatmultilinetr "$CPPSTATICATTRS" '\n\n')
    CPPCONSTRUCTOR=$(formatmultilinetr "$CPPCONSTRUCTOR" '\n\n')
    CPPDESTRUCTOR=$(formatmultilinetr "$CPPDESTRUCTOR" '\n\n')
    CPPGETTERS=$(formatmultilinetr "$CPPGETTERS" '\n\n// Getters\n')
    CPPSETTERS=$(formatmultilinetr "$CPPSETTERS" '\n\n// Setters\n')
    CPPMETHODS=$(formatmultilinetr "$CPPMETHODS" '\n\n// Methods\n')
    cat >"$1.cpp" <<-END
		$CPPINCLUDES${CPPSTATICATTRS}${CPPCONSTRUCTOR}${CPPDESTRUCTOR}${CPPGETTERS}${CPPSETTERS}${CPPMETHODS}
	END
}

createstdimport() {
    if [ "$1" = "$2" ] && ! regexmatch "$HIMPORTS" ".*#include <$2>.*"; then
        HIMPORTS="$HIMPORTS\n#include <$2>"
        HNAMESPACESTD='using namespace std;'
    fi
}

creategeneralimports() {
    SEPARATEDTYPESARRAY=(`echo ${2//[, <>\*0-9\[\]]/ }`);
    for TYPE in "${SEPARATEDTYPESARRAY[@]}"; do
        if ! [ "$TYPE" = "$1" ] && regexmatch "$TYPE" '^[A-Z]' && ! regexmatch "$HLOCALIMPORTS" ".*$TYPE.*"; then
            HLOCALIMPORTS="$HLOCALIMPORTS\n#include \"$TYPE.h\""
        else
            for STDTYPE in 'string' 'vector' 'list' 'forward-list' 'deque' 'map' 'multimap' 'set'; do
                createstdimport "$TYPE" "$STDTYPE"
            done
        fi
    done
}

createcppattr() {
    ATTRVALUE=''
    ATTRNAMEAPPEND=''
    ATTRNAMEPREPEND=''
    STATICTYPE=''
    STATICPREPEND=''
    if regexmatch "$ATTRNAME" '.* *= *.*'; then
        ATTRVALUE=" = $(printf "$ATTRNAME" | sed -e "s/.*= *//g")"
        ATTRNAME=$(printf "$ATTRNAME" | sed -e "s/ *=.*//g")
    fi
    if regexmatch "$ATTRTYPE" 'static '; then
        ATTRTYPE=$(printf "$ATTRTYPE" | sed "s/static //")
        STATICTYPE='static '
        STATICPREPEND="$1::"
        CPPSTATICATTRS="${CPPSTATICATTRS}$ATTRTYPE ${STATICPREPEND}$ATTRNAME;\n"
    fi
    creategeneralimports "$1" "$ATTRTYPE"
    if regexmatch "$ATTRTYPE" '.*\[.*\].*'; then
        ATTRMAXLENGTH=$(printf "$ATTRTYPE" | sed -e "s/.*\[//g" -e "s/\]//g")
        ATTRTYPE=$(printf "$ATTRTYPE" | sed -e "s/\[.*\]//g")
        UPPERCASE=$(printf "$ATTRNAME" | tr '[:lower:]' '[:upper:]')
        HDEFINITIONS="$HDEFINITIONS\n#define MAXIMO_$UPPERCASE $ATTRMAXLENGTH"
        ATTRNAMEAPPEND="[MAXIMO_${UPPERCASE}]"
        ATTRNAMEPREPEND="*"
    fi
    CAPITALIZED=$(perl -lne 'use open qw(:std :utf8); print ucfirst' <<<$ATTRNAME)
    if ([ $CREATEHSETTER = true ] || [ $CREATECPPSETTER = true ]) && ! regexmatch "$ATTRTYPE" '^const ' && [ -z "$ATTRNAMEPREPEND" ] && [ -z "$STATICTYPE" ]; then
        CONSTRUCTORPARAMS="${CONSTRUCTORPARAMS}${CONSTRUCTORCOMMA}${ATTRTYPE}$ATTRNAMEPREPEND ${ATTRNAME}"
        CPPCONSTRUCTORATTRIBUTION="$CPPCONSTRUCTORATTRIBUTION${CONSTRUCTORCOMMA}\n    $ATTRNAME($ATTRNAME)"
        CONSTRUCTORCOMMA=', '
        ATTRSETTERPARAM="set$CAPITALIZED($ATTRTYPE $ATTRNAME)"
        [ $CREATEHSETTER = true ] && HSETTERS="$HSETTERS\n    void ${ATTRSETTERPARAM};"
        [ $CREATECPPSETTER = true ] && CPPSETTERS="${CPPSETTERS}void $1::${ATTRSETTERPARAM} { this->$ATTRNAME = $ATTRNAME; }\n\n"
    fi
    HATTRS="$HATTRS\n    ${STATICTYPE}$ATTRTYPE ${ATTRNAME}${ATTRNAMEAPPEND}$ATTRVALUE;"
    [ $CREATEHGETTER = true ] && HGETTERS="$HGETTERS\n    ${STATICTYPE}${ATTRTYPE}$ATTRNAMEPREPEND get$CAPITALIZED();"
    [ $CREATECPPGETTER = true ] && CPPGETTERS="${CPPGETTERS}${ATTRTYPE}$ATTRNAMEPREPEND $1::get$CAPITALIZED() { return ${STATICPREPEND}$ATTRNAME; }\n\n"
}

createcppmethod() {
    METHODVIRTUALTYPE=''
    METHODSTATICTYPE=''
    if regexmatch "$METHODTYPE" 'virtual '; then
        METHODTYPE=$(printf "$METHODTYPE" | sed "s/virtual //")
        METHODVIRTUALTYPE='virtual '
    fi
    if regexmatch "$METHODTYPE" 'static '; then
        METHODTYPE=$(printf "$METHODTYPE" | sed "s/static //")
        METHODSTATICTYPE='static '
    fi
    creategeneralimports "$1" "$METHODTYPE"
    [ $CREATEHMETHOD = true ] && HMETHODS="$HMETHODS\n    ${METHODVIRTUALTYPE}${METHODSTATICTYPE}$METHODTYPE $METHODNAME($METHODPARAMS);"
    CPPMETHODS="${CPPMETHODS}$METHODTYPE $1::$METHODNAME($METHODPARAMS) {\n    // TODO: adicionar código\n}\n\n"
}

cppclass() {
    if checkparam "$1" "Você deve passar o nome da classe como parâmetro."; then
        return 1
    fi
    printf "\nCriando a classe ${TTYBOLD}$1$TTYRESET! $FACTORY\n\n"
    HIMPORTS=''
    HNAMESPACESTD=''
    HLOCALIMPORTS=''
    HPARENTIMPORTS=''
    HDEFINITIONS=''
    HPARENTNAMES=''
    HATTRS=''
    HGETTERS=''
    HSETTERS=''
    HMETHODS=''
    CPPSTATICATTRS=''
    CONSTRUCTORCOMMA=''
    CONSTRUCTORPARENTCOMMA=''
    CONSTRUCTORPARAMS=''
    CPPCONSTRUCTORATTRIBUTION=''
    CPPCONSTRUCTORPARENTATTRIBUTION=''
    HDESTRUCTOR=''
    CPPDESTRUCTOR=''
    CPPGETTERS=''
    CPPSETTERS=''
    CPPMETHODS=''
    CPPADDITIONALINCLUDES=''
    CREATEHGETTER=true
    CREATEHSETTER=true
    CREATECPPGETTER=true
    CREATECPPSETTER=true
    CREATEHMETHOD=true
    printf -- "---- 1/3 ${TTYBOLD}ATRIBUTOS$TTYRESET $POPCORN----\n"
    while true; do
        readinput "\nNome (ou ${TTYBOLD}ENTER$TTYRESET para pular):" ATTRNAME
        [ "$ATTRNAME" = '' ] && break
        readinput "\nTipo (string, int, int[10] etc.):" ATTRTYPE
        createcppattr "$1"
    done
    printf "\n----- 2/3 ${TTYBOLD}MÉTODOS$TTYRESET $WRENCH-----\n"
    while true; do
        readinput "\nNome (ou ${TTYBOLD}ENTER$TTYRESET para pular):" METHODNAME
        [ "$METHODNAME" = '' ] && break
        readinput "\nTipo de retorno (int, void etc.):" METHODTYPE
        readinput "\nLista de parâmetros (ex.: \"string nome, int contatos[]\"):" METHODPARAMS
        createcppmethod "$1"
    done
    printf "\n----- 3/3 ${TTYBOLD}CONFIGURAÇÕES$TTYRESET $WRENCH-----\n"
    if yesorno "\nIncluir um destrutor?"; then
        HDESTRUCTOR="virtual ~$1();"
        CPPDESTRUCTOR="$1::~$1() {}"
    fi
    STDEXCEPT='logic_error|domain_error|invalid_argument|length_error|out_of_range|runtime_error|range_error|overflow_error|underflow_error'
    STDEXCEPTADDED=false
    if yesorno "\nPossui classe(s) pai?"; then
        while true; do
            readinput "\nNome do pai (ou ${TTYBOLD}ENTER$TTYRESET para pular):" CPARENTCLASSNAME
            [ "$CPARENTCLASSNAME" = '' ] && break
            CPPCONSTRUCTORPARENTATTRIBUTION="$CPPCONSTRUCTORPARENTATTRIBUTION${CONSTRUCTORPARENTCOMMA}\n    $CPARENTCLASSNAME()"
            if [ $STDEXCEPTADDED = false ] && regexmatch "$CPARENTCLASSNAME" "$STDEXCEPT"; then
                HIMPORTS="\n#include <stdexcept>$HIMPORTS"
                HNAMESPACESTD='using namespace std;'
                STDEXCEPTADDED=true
            else
                HPARENTIMPORTS="$HPARENTIMPORTS\n#include \"$CPARENTCLASSNAME.h\""
            fi
            HPARENTNAMES="${HPARENTNAMES}${CONSTRUCTORPARENTCOMMA}public $CPARENTCLASSNAME"
            CONSTRUCTORPARENTCOMMA=', '
        done
        [ ! -z "$CPPCONSTRUCTORATTRIBUTION" ] && CPPCONSTRUCTORPARENTATTRIBUTION="${CPPCONSTRUCTORPARENTATTRIBUTION}$CONSTRUCTORPARENTCOMMA"
    fi
    HIMPORTS=$(formatmultilinetr "$HIMPORTS" '\n')
    HNAMESPACESTD=$(formatmultilinetr "$HNAMESPACESTD" '\n')
    HLOCALIMPORTS=$(formatmultilinetr "$HLOCALIMPORTS" '\n')
    HPARENTIMPORTS=$(formatmultilinetr "$HPARENTIMPORTS" '\n')
    HDEFINITIONS=$(formatmultilinetr "$HDEFINITIONS" '\n')
    HIMPORTSANDDEFINITIONS="${HIMPORTS}${HNAMESPACESTD}${HLOCALIMPORTS}${HPARENTIMPORTS}${HDEFINITIONS}"
    HPRIVATEANDPROTECTED=$(formatmultilinetr "$HATTRS" '   private:')
    HCONSTRUCTOR=$(formatmultilinetr "$1($CONSTRUCTORPARAMS);" '\n    ')
    CPPCONSTRUCTORATTRIBUTION=$(formatmultilinetr "${CPPCONSTRUCTORPARENTATTRIBUTION}$CPPCONSTRUCTORATTRIBUTION" ':')
    CPPCONSTRUCTOR="$1::$1($CONSTRUCTORPARAMS)$CPPCONSTRUCTORATTRIBUTION {}"
    CPPINCLUDES="#include \"$1.h\""
    if checkoverwrite "$1.h" "$1.cpp"; then
        createhclass "$1"
        createcppclass "$1"
        printf "Arquivos ${LIGHTBLUE}$1.h$NOCOLOR e ${LIGHTBLUE}$1.cpp$NOCOLOR criados na sua pasta! $SUCCESS\n"
        finalprint
    fi
}

cppmissing() {
    if checkparam "$1" "Você deve passar o nome da classe como parâmetro."; then
        return 1
    fi

    # Remover ".", ".h" ou ".cpp"
    CLSNAME=$(printf "$1" | sed -e "s/\..*//g")

    if ! [ -f "$CLSNAME.h" ]; then
        printf "\nO arquivo ${LIGHTBLUE}$CLSNAME.h$NOCOLOR não existe nesta pasta.\n"
        finalprint
        return 1
    fi

    CREATEGETTERS=false
    if yesorno "\nCriar ${LIGHTBLUE}getters${NOCOLOR} para todos os atributos?"; then
        CREATEGETTERS=true
        printf '\n'
    fi

    CREATESETTERS=false
    if yesorno "Criar ${LIGHTBLUE}setters${NOCOLOR} para todos os atributos?"; then
        CREATESETTERS=true
    fi

    # Em Windows, converter para LF
    if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
        dos2unix -q "$1.h"
        dos2unix -q "$1.cpp"
    fi

    printf "\nCriando atributos e métodos faltantes em ${LIGHTBLUE}$CLSNAME.h${NOCOLOR} e ${LIGHTBLUE}$CLSNAME.cpp${NOCOLOR}... "

    [ -f "$CLSNAME.cpp" ] || printf '\n' >> "$CLSNAME.cpp"

    getlineno() {
        printf "$(grep -n -m 1 "$1" <(printf "$2") | sed 's/\([0-9]*\).*/\1/')"
    }

    LINEBREAKSUB='SUBSTITUTODEQUEBRADELINHA'

    HCLSTXTWHOLE=$(cat "$CLSNAME.h" | sed s/\\\\n/$LINEBREAKSUB/g)

    HCLASSBODY=$(awk "/^\};$/{include=0} include==1{print} /^class ${CLSNAME}[^;]/{include=1}" <(printf "$HCLSTXTWHOLE"))

    HMETHODS=''
    HSETTERS=''
    HGETTERS=''
    HPUBLIC=''
    HPRIVATEANDPROTECTED=''

    HPARENTNAMES=$(grep "^class ${CLSNAME}[^;]" <(printf "$HCLSTXTWHOLE") | sed -e 's/ *{.*//' -e "s/class $CLSNAME:* *//")

    MATCHLINENO=$(getlineno "\/\/ Methods" "$HCLASSBODY")
    if ! [ -z "$MATCHLINENO" ]; then
        HMETHODS="\n$(awk "NR>${MATCHLINENO}" <(printf "$HCLASSBODY"))"
        HCLASSBODY=$(awk "NR<${MATCHLINENO}" <(printf "$HCLASSBODY"))
    fi

    MATCHLINENO=$(getlineno "\/\/ Setters" "$HCLASSBODY")
    if ! [ -z "$MATCHLINENO" ]; then
        HSETTERS="\n$(awk "NR>${MATCHLINENO}" <(printf "$HCLASSBODY"))"
        HCLASSBODY=$(awk "NR<${MATCHLINENO}" <(printf "$HCLASSBODY"))
    fi

    MATCHLINENO=$(getlineno "\/\/ Getters" "$HCLASSBODY")
    if ! [ -z "$MATCHLINENO" ]; then
        HGETTERS="\n$(awk "NR>${MATCHLINENO}" <(printf "$HCLASSBODY"))"
        HCLASSBODY=$(awk "NR<${MATCHLINENO}" <(printf "$HCLASSBODY"))
    fi

    MATCHLINENO=$(getlineno "public:" "$HCLASSBODY")
    if ! [ -z "$MATCHLINENO" ]; then
        HPUBLIC="$(awk "NR>${MATCHLINENO}" <(printf "$HCLASSBODY"))"
        HCLASSBODY=$(awk "NR<${MATCHLINENO}" <(printf "$HCLASSBODY"))
    fi

    MATCHLINENO=$(getlineno "[(private)|(protected)]:" "$HCLASSBODY")
    if ! [ -z "$MATCHLINENO" ]; then
        MATCHLINENO=$(($MATCHLINENO - 1))
        HPRIVATEANDPROTECTED="$(awk "NR>${MATCHLINENO}" <(printf "$HCLASSBODY"))"
        HCLASSBODY=$(awk "NR<=${MATCHLINENO}" <(printf "$HCLASSBODY"))
    fi

    [ -z "$HCLASSBODY" ] || HCLASSBODY="$HCLASSBODY\n\n"

    HPRIVATEANDPROTECTED="$HCLASSBODY$HPRIVATEANDPROTECTED"

    CPPCLSTXTWHOLE=$(cat "$CLSNAME.cpp" | sed s/\\\\n/$LINEBREAKSUB/g)
    CPPCLSTXT="$CPPCLSTXTWHOLE"

    CPPMETHODS=''
    CPPSETTERS=''
    CPPGETTERS=''
    CPPDESTRUCTOR=''
    CPPCONSTRUCTOR=''
    CONSTRUCTORCOMMA=''
    CONSTRUCTORPARAMS=''
    CPPCONSTRUCTORATTRIBUTION=''
    CPPSTATICATTRS=''

    MATCHLINENO=$(getlineno "\/\/ Methods" "$CPPCLSTXT")
    if ! [ -z "$MATCHLINENO" ]; then
        CPPMETHODS="$(awk "NR>${MATCHLINENO}" <(printf "$CPPCLSTXT"))\n\n"
        CPPCLSTXT=$(awk "NR<${MATCHLINENO}" <(printf "$CPPCLSTXT"))
    fi

    MATCHLINENO=$(getlineno "\/\/ Setters" "$CPPCLSTXT")
    if ! [ -z "$MATCHLINENO" ]; then
        CPPSETTERS="$(awk "NR>${MATCHLINENO}" <(printf "$CPPCLSTXT"))\n\n"
        CPPCLSTXT=$(awk "NR<${MATCHLINENO}" <(printf "$CPPCLSTXT"))
    fi

    MATCHLINENO=$(getlineno "\/\/ Getters" "$CPPCLSTXT")
    if ! [ -z "$MATCHLINENO" ]; then
        CPPGETTERS="$(awk "NR>${MATCHLINENO}" <(printf "$CPPCLSTXT"))\n\n"
        CPPCLSTXT=$(awk "NR<${MATCHLINENO}" <(printf "$CPPCLSTXT"))
    fi

    # Se ainda possuir métodos, considerar que tudo é CPPMETHODS
    MATCHLINENO=$(getlineno " $CLSNAME::[a-zA-Z]*(" "$CPPCLSTXT")
    if ! [ -z "$MATCHLINENO" ]; then
        CPPMETHODS="$CPPMETHODS$(awk "NR>$(($MATCHLINENO - 1))" <(printf "$CPPCLSTXT"))\n\n"
        CPPCLSTXT=$(awk "NR<${MATCHLINENO}" <(printf "$CPPCLSTXT"))
    fi

    MATCHLINENO=$(getlineno "^$CLSNAME::~$CLSNAME(" "$CPPCLSTXT")
    if ! [ -z "$MATCHLINENO" ]; then
        MATCHLINENO=$(($MATCHLINENO - 1))
        CPPDESTRUCTOR="$(awk "NR>${MATCHLINENO}" <(printf "$CPPCLSTXT"))\n\n"
        CPPCLSTXT=$(awk "NR<${MATCHLINENO}" <(printf "$CPPCLSTXT"))
    fi

    MATCHLINENO=$(getlineno "^$CLSNAME::$CLSNAME(" "$CPPCLSTXT")
    if ! [ -z "$MATCHLINENO" ]; then
        MATCHLINENO=$(($MATCHLINENO - 1))
        CPPCONSTRUCTOR="$(awk "NR>${MATCHLINENO}" <(printf "$CPPCLSTXT"))\n\n"
        CPPCLSTXT=$(awk "NR<=${MATCHLINENO}" <(printf "$CPPCLSTXT"))
    fi

    MATCHLINENO=$(getlineno "$CLSNAME::" "$CPPCLSTXT")
    if ! [ -z "$MATCHLINENO" ]; then
        MATCHLINENO=$(($MATCHLINENO - 1))
        CPPSTATICATTRS="$(awk "NR>${MATCHLINENO}" <(printf "$CPPCLSTXT"))"
        CPPCLSTXT=$(awk "NR<${MATCHLINENO}" <(printf "$CPPCLSTXT"))
    fi

    CPPINCLUDES="$CPPCLSTXT"

    INSIDECLASS=false
    NOPRINTS=true

    elemadded() {
        [ $NOPRINTS = true ] && printf '\n' && NOPRINTS=false
        printf "+ ${GREEN}$1$NOCOLOR\n"
    }

    while read -r LINE; do
        regexmatch "$LINE" "class ${CLSNAME}[^;]" && INSIDECLASS=true
        regexmatch "$LINE" '\};$' && INSIDECLASS=false
        [ $INSIDECLASS = false ] || [ -z "$LINE" ] || regexmatch "$LINE" "^class ${CLSNAME}[^;]|^private:|^protected:|^public:|^//" && continue;
        # Se for um atributo
        if ! regexmatch "$LINE" '\('; then
            ATTRNAME=$(printf "$LINE" | sed -e "s/\( *=.*\)*;$//g" -e "s/[^ ]* //g")
            CAPITALIZED=$(perl -lne 'use open qw(:std :utf8); print ucfirst' <<<$ATTRNAME)
            ATTRTYPE=$(printf "$LINE" | sed "s/ \{1,\}$ATTRNAME.*//g")
            CREATECPPGETTER=false
            if ! regexmatch "$CPPCLSTXTWHOLE" "$CLSNAME::get$CAPITALIZED\(" && [ $CREATEGETTERS = true ]; then
                elemadded "get${CAPITALIZED}"
                CREATECPPGETTER=true
            fi
            CREATECPPSETTER=false
            if ! regexmatch "$ATTRTYPE" "static |const " && ! regexmatch "$CPPCLSTXTWHOLE" "$CLSNAME::set$CAPITALIZED\(" && [ $CREATESETTERS = true ]; then
                elemadded "set${CAPITALIZED}"
                CREATECPPSETTER=true
            fi
            CREATEHGETTER=false
            if ! regexmatch "$HCLSTXTWHOLE" "get$CAPITALIZED\(" && [ $CREATEGETTERS = true ]; then
                [ $CREATECPPGETTER = false ] && elemadded "get${CAPITALIZED}"
                CREATEHGETTER=true
            fi
            CREATEHSETTER=false
            if ! regexmatch "$ATTRTYPE" "static |const " && ! regexmatch "$HCLSTXTWHOLE" "set$CAPITALIZED\(" && [ $CREATESETTERS = true ]; then
                [ $CREATECPPSETTER = false ] && elemadded "set${CAPITALIZED}"
                CREATEHSETTER=true
            fi
            CREATESTATICATTR=false
            TYPEWITHOUTSTATIC=$(printf "$ATTRTYPE" | sed "s/static //")
            if regexmatch "$ATTRTYPE" "static " && ! regexmatch "$CPPCLSTXTWHOLE" "$TYPEWITHOUTSTATIC $CLSNAME::$ATTRNAME"; then
                elemadded "${ATTRNAME}"
                CREATESTATICATTR=true
            fi
            if [ $CREATECPPGETTER = true ] || [ $CREATECPPSETTER = true ] || [ $CREATEHGETTER = true ] || [ $CREATEHSETTER = true ] || [ $CREATESTATICATTR = true ]; then
                createcppattr "$CLSNAME"
            fi
        # Se for um método
        else
            # Se for construtor ou destrutor, ignorar
            regexmatch "$LINE" "$CLSNAME\(" && continue
            METHODNAME=$(printf "$LINE" | sed -e "s/(.*//g" -e "s/[^ ]* //g")
            # Se já estiver implementado, ignorar
            CPPAMALGOM="$CPPCLSTXTWHOLE\n$CPPGETTERS\n$CPPSETTERS"
            regexmatch "$CPPAMALGOM" "$CLSNAME::$METHODNAME\(" && continue
            elemadded "${METHODNAME}"
            METHODPARAMS=$(printf "$LINE" | sed -e "s/.*(//g" -e "s/).*//g")
            METHODTYPE=$(printf "$LINE" | sed "s/ \{1,\}$METHODNAME(.*//g")
            CREATEHMETHOD=false
            createcppmethod "$CLSNAME"
        fi
    done < "$CLSNAME.h"

    [ $NOPRINTS = false ] && printf "$ROCKET Feito!\n" || printf "Nenhum faltante.\n"

    finalprint

    UPPERCASE=$(printf "$CLSNAME" | tr '[:lower:]' '[:upper:]')
    HIMPORTSANDDEFINITIONS=$(awk "/^class ${CLSNAME}[^;]/{ignore=1} /^#ifndef [a-zA-Z]*/{ignore=1} ignore==0{print} /^#define [a-zA-Z]*/{ignore=0}" <(printf "$HCLSTXTWHOLE"))
    HIMPORTSANDDEFINITIONS=$(formatmultilinetr "$HIMPORTSANDDEFINITIONS" '\n')
    HCONSTRUCTOR=$(formatmultilinetr "$HPUBLIC" '\n')
    HDESTRUCTOR=''
    CPPINCLUDES=$([ -z "$CPPINCLUDES" ] && printf "#include \"$CLSNAME.h\"\n" || printf "$CPPINCLUDES")
    CPPCONSTRUCTOR=$([ -z "$CPPCONSTRUCTOR" ] && printf "$CLSNAME::$CLSNAME($CONSTRUCTORPARAMS)$CPPCONSTRUCTORATTRIBUTION {}" || printf "$CPPCONSTRUCTOR")
    CPPDESTRUCTOR=$([ -z "$CPPDESTRUCTOR" ] && printf "$CLSNAME::~$CLSNAME() {}" || printf "$CPPDESTRUCTOR")
    regexmatch "$HCLSTXTWHOLE" "~$CLSNAME\(" || CPPDESTRUCTOR=''

    replacelinebreak() {
        if [ $OS = 'Darwin' ]; then
            sed -i '' -e "s/$LINEBREAKSUB/\\\\n/g" "$1"
        else
            sed -i -- "s/$LINEBREAKSUB/\\\\n/g" "$1"
        fi
    }

    createhclass "$CLSNAME"
    replacelinebreak "$CLSNAME.h"
    createcppclass "$CLSNAME"
    replacelinebreak "$CLSNAME.cpp"
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
    printf "\n${LIGHTBLUE}.vscode/settings.json${NOCOLOR} configurado! Agora arquivos .a.out e .a.out.dSYM ficarão invisíveis no VSCode.\n"
    finalprint
}

cppzipsinglefile() {
    if [ $3 = true ]; then
        awk 'BEGIN{ brackets=999 } /int main()/{ print "/*"; brackets=0 } /\{/{ brackets++ } /\}/{ brackets-- } brackets==0{ print "}\n*/"; stop=1; brackets=999 } stop==0{print}' $1 >tmp
        if ! diff "$1" tmp >> /dev/null; then
            printf "Função main encontrada em ${LIGHTBLUE}$1${NOCOLOR}\n"
        fi
        cp "$1" "$1.tmp"
        cp tmp "$1"
        zip "$2" "$1" >> /dev/null
        cp "$1.tmp" "$1"
        rm tmp "$1.tmp"
    else
        zip "$2" "$1" >> /dev/null
    fi
}

cppzip() {
    CCOMMENTMAIN=false
    if yesorno "\nVocê deseja comentar a função main?"; then
        CCOMMENTMAIN=true
        printf '\n'
    fi
    QUANTITY=0
    [ $SHELL = '/bin/zsh' ] && setopt +o nomatch || shopt -s nullglob
    for f in *.{cpp,h}; do
        regexmatch "$f" '^\*' && continue
        cppzipsinglefile "$f" files $CCOMMENTMAIN
        QUANTITY=$(($QUANTITY+1))
    done
    printf "\n$QUANTITY $([ $QUANTITY = 1 ] && printf 'arquivo comprimido e salvo' || printf 'arquivos comprimidos e salvos') em ${LIGHTBLUE}files.zip${NOCOLOR}!\n"
    finalprint
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

TABSNO=4

if [ $OS = 'Darwin' ]; then
    FAKETABS=$(printf "        %.0s" $(seq 1 $TABSNO))
    printcommand() {
        printf "${GREEN}$1 ${LIGHTBLUE}$2${NOCOLOR}$(printf "${"$(printf "\n$3" | fmt -w $((COLUMNS - ${#FAKETABS} - ${#LINEBREAK})) | sed -e ':a' -e 'N' -e '$!ba' -e "s/\n/\n$FAKETABS/g")":${#1} + ${#2} + 2}" | sed "s/$FAKETABS/${FAKETABS}$LINEBREAK/g")\n\n"
    }
else
    REALTABS=$(printf "	%.0s" $(seq 1 $TABSNO))
    printcommand() {
        DESC=$(printf "${REALTABS}$3" | fmt -w $COLUMNS)
        printf "${GREEN}$1 ${LIGHTBLUE}$2${NOCOLOR}${DESC:(${#1} + ${#2} + 1) / 8}\n\n"
    }
fi

chelp() {
    printf "\nComandos para rodar programas em C/C++! $COMPUTER\n\n"
    printcommand 'cnew' '[nome do arquivo]' 'gera um novo arquivo C na pasta atual, com um template inicial.'
    printcommand 'crun' '[nome do arquivo.c]' "compila e roda um código em C (use \\${TTYBOLD}TAB\\$TTYRESET para completar o nome do arquivo ao escrever na linha de comando)."
    printcommand 'cppnew' '[nome do projeto]' 'gera um novo projeto de C++ na pasta atual, com um template inicial.'
    printcommand 'cppclass' '[nome da classe]' "gera um par de arquivos .h e .cpp na pasta atual, a partir das informações dadas na linha de comando, além de automaticamente criar setters e getters para todos os atributos."
    printcommand 'cppmissing' '[nome da classe]' "analisa um arquivo de cabeçalho da classe já existente, gerando todos os atributos e métodos faltantes no respectivo arquivo de implementação, assim como opcionalmente criando getters e setters para todos seus atributos."
    printcommand 'cpprun' '' "compila todos os arquivos C++ da pasta atual, rodando a função main. Deve ser rodado na pasta do projeto. \\${TTYBOLD}IMPORTANTE:\\$TTYRESET se a pasta atual possuir mais de um projeto, ocorrerá um erro."
    printcommand 'out' '' "roda o último código em C/C++ compilado com \\${LIGHTBLUE}crun\\$NOCOLOR ou \\${LIGHTBLUE}cpprun\\$NOCOLOR na pasta atual."
    printcommand 'ctempl' '[nome do arquivo.c]' 'redefine o template inicial para arquivos C.'
    printcommand 'cppzip' '' "localiza e comenta o main do projeto, criando o \\${TTYBOLD}files.zip\\$TTYRESET com todos os arquivos .h e .cpp da pasta atual."
    printcommand 'hidevscc' '' 'caso esteja usando VS Code, este comando torna invisíveis os arquivos de compilação para não poluir a área de trabalho.'
    printcommand 'cupdate' '' "baixa e atualiza o \\${TTYBOLD}Better C/C++ Tools\\$TTYRESET para a última versão disponível."
    printf "${TTYBOLD}Better C/C++ Tools v${BETTERCCPPVERS}$TTYRESET - feito por $LIGHTBLUE@henriquefalconer$NOCOLOR (https://github.com/henriquefalconer)\n\n"
    printf "Sugestões ou problemas podem ser submetidos aqui: ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues$TTYRESET\n"
    ccheckupdate
}

# ------ End of Better C/C++ Tools ------
