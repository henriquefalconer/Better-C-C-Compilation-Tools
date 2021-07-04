#!/bin/bash

abort() {
    printf "$1\n\n"
    exit 1
}

if [ -z "${BASH_VERSION:-}" ]; then
    abort "\nBash é necessário para rodar este script."
fi

# Formatação de strings
LIGHTBLUE='\e[94m'
PURPLE='\e[0;35m'
GREEN='\e[32m'
NOCOLOR='\e[0m'
TTYBOLD="\033[1;39m"
TTYRESET="\033[1;0m"
TEMPLATEI='📄'
DOWNLOADI='⬇️'
SAVEI='📀'
SUCCESS='🎉'

# Obtém o valor que corresponde com a chave passada do JSON de informações da última versão do projeto.
getlatestversiondata() {
    printf "$(awk "/^  \"$1\": .+/{print}" <(printf "%s\n" "$CCPPRELEASES") | sed -e "s/^  \"$1\": \"\{0,1\}//g" -e "s/\"\{0,1\},\{0,1\}$//g")"
}

# Realiza o curl para obter o JSON da última versão, caso esteja instalando pela primeira vez.
if [ -z "$LATESTVERSIONNAME" ]; then
    CCPPRELEASES=$(curl -s 'https://api.github.com/repos/henriquefalconer/better-c-cpp-tools/releases/latest')
    if [[ "$CCPPRELEASES" =~ .*"API rate limit exceeded".* ]]; then
        abort "A API do GitHub restringiu seu acesso às versões do projeto. Adicione um tópico em ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues${TTYRESET} e tente novamente mais tarde."
    fi
    LATESTVERSIONNAME=$(getlatestversiondata name)
fi

# Realiza o curl para obter os templates.
printf "1/3 $TEMPLATEI Baixando templates de C/C++..."
mkdir -p "$HOME/.ccpptemplates/cpp/raw"
mkdir -p "$HOME/.ccpptemplates/cpp/withio"
curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/templates/template.c >"$HOME/.ccpptemplates/template.c"
curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/templates/cpp/raw/main.cpp >"$HOME/.ccpptemplates/cpp/raw/main.cpp"
curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/templates/cpp/withio/iofuncs.h >"$HOME/.ccpptemplates/cpp/withio/iofuncs.h"
curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/templates/cpp/withio/main.cpp >"$HOME/.ccpptemplates/cpp/withio/main.cpp"
printf " Feito!\n\n"

BETTERCCPPSTART='# ------ Start of Better C/C++ Tools ------'
BETTERCCPPEND='# ------ End of Better C/C++ Tools ------'
BETTERCCPPSTARTRGX='# ------ Start of Better C\/C\+\+ Tools ------'
BETTERCCPPENDRGX='# ------ End of Better C\/C\+\+ Tools ------'

clearold() {
    if [ -f "$1" ]; then
        awk "/$BETTERCCPPSTARTrgx/{stop=1} stop==0{print} /$BETTERCCPPENDrgx/{stop=0}" "$1" > .tmpbettercpp && mv .tmpbettercpp "$1"
        [ -f .tmpbettercpp ] && rm .tmpbettercpp
    fi
}

# Realiza o curl para obter código.
savefuncs() {
    printf "2/3 $DOWNLOADI  Baixando novos comandos de C/C++..."
    clearold "$1"
    printf "\n$BETTERCCPPSTART\n\n" >>"$1"
    curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/LICENSE.md | sed '/[^\(^$\)]/s/^/# /' >>"$1"
    curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/funcs.sh >>"$1"
    printf "\n$BETTERCCPPEND\n" >>"$1"
    printf " Feito!\n\n"
    printf "3/3 $SAVEI Salvando-os em ${LIGHTBLUE}$1${NOCOLOR}..."
    sed -i -e "s/BETTERCCPPVERS='X.X.X'/\n\nBETTERCCPPVERS='$LATESTVERSIONNAME'/g" "$1"
    printf " Salvos!\n\n"
}

# Seleciona o path de instalação.
if [[ "$SHELL" == "/bin/zsh" ]]; then
    savefuncs "$HOME/.zshenv"
else
    savefuncs "$HOME/.bashrc"
    if [ ! -f "$HOME/.bash_profile" ]; then
        cat >"$HOME/.bash_profile" <<-END
			test -f "$HOME/.profile" && . "$HOME/.profile"
			test -f "$HOME/.bashrc" && . "$HOME/.bashrc"
		END
    fi
fi

# Aguarda input do usuário para mostrar novos comandos.
printf "$SUCCESS Configuração feita! para começar a utilizar, feche o VSCode, abra-o novamente e rode ${LIGHTBLUE}chelp${NOCOLOR}."
