#!/bin/bash

abort() {
    printf "$1\n\n"
    exit 1
}

if [ -z "${BASH_VERSION:-}" ]; then
    abort "\nBash é necessário para rodar este script."
fi

# Primeiro verifica o sistema operacional.
OS="$(uname)"
if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
    abort "\nEste script apenas suporta macOS e Linux."
fi

# Formatação de strings
LIGHTBLUE='\e[94m'
PURPLE='\e[0;35m'
GREEN='\e[32m'
NOCOLOR='\e[0m'
TTYBOLD="\033[1;39m"
TTYRESET="\033[1;0m"

# Obtém o valor que corresponde com a chave passada do JSON de informações da última versão do projeto.
getlatestversiondata() {
    printf "$(awk "/^  \"$1\": .+/{print}" <(printf "%s\n" "$CCPPRELEASES") | sed -e "s/^  \"$1\": \"\{0,1\}//g" -e "s/\"\{0,1\},\{0,1\}$//g")"
}

# Realiza o curl para obter o JSON da última versão, caso esteja instalando pela primeira vez.
if [ -z "$LATESTVERSIONNAME" ]; then
    CCPPRELEASES=$(curl -s 'https://api.github.com/repos/henriquefalconer/better-c-cpp-tools/releases/latest')
    if [[ $CCPPRELEASES =~ .*"API rate limit exceeded".* ]]; then
        abort "A API do GitHub restringiu seu acesso às versões do projeto. Adicione um tópico em ${TTYBOLD}https://github.com/henriquefalconer/better-c-cpp-tools/issues${TTYRESET} e tente novamente mais tarde."
    fi
    LATESTVERSIONNAME=$(getlatestversiondata name)
fi

# Realiza o curl para obter os templates.
printf "1/3 📄 Baixando templates de C/C++..."
curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/templates/template.c >~/.template.c
curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/templates/template.cpp >~/.template.cpp
printf " Feito!\n\n"

clearold() {
    BETTERCCPPSTART='# ------ Start of Better C\/C\+\+ Tools ------'
    BETTERCCPPEND='# ------ End of Better C\/C\+\+ Tools ------'
    awk "/$BETTERCCPPSTART/{stop=1} stop==0{print} /$BETTERCCPPEND/{stop=0}" $1 > .tmp && mv .tmp $1
}

# Realiza o curl para obter código.
savefuncs() {
    printf "2/3 ⬇️  Baixando novos comandos de C/C++..."
    clearold $1
    curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/feat/versioning/funcs.sh >>$1
    printf " Feito!\n\n"
    printf "3/3 📀 Salvando-os em ${LIGHTBLUE}$1${NOCOLOR}..."
    sed -i -e "s/BETTERCCPPVERS='X.X.X'/BETTERCCPPVERS='$LATESTVERSIONNAME'/g" $1
    source $1
    printf " Salvos!\n\n"
}

# Seleciona o path de instalação.
if [[ "$SHELL" == "/bin/zsh" ]]; then
    savefuncs ~/.zshenv
else
    savefuncs ~/.bashrc
fi

# Verifica se os comandos foram carregados com o "source".
if [ "$LATESTVERSIONNAME" != "$BETTERCCPPVERS" ]; then
    abort "🎉 Configuração feita! para começar a utilizar, feche este shell, abra-o novamente e rode ${LIGHTBLUE}chelp${NOCOLOR}."
fi

# Aguarda input do usuário para mostrar novos comandos.
printf "🎉 Configuração feita! para visualizar a lista de comandos, basta rodar ${LIGHTBLUE}chelp${NOCOLOR}.\n\n"
