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

# Realiza o curl para obter código.
savefuncs() {
    printf "\n1/3 ⬇️  Baixando novos comandos de C/C++..."
    curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-compilation-tools/main/funcs.sh >>$1
    printf " Feito!\n\n"
    printf "2/3 📀 Salvando-os em ${LIGHTBLUE}$1${NOCOLOR}..."
    source $1
    printf " Salvo!\n\n"
}

# Seleciona o path de instalação.
if [[ "$SHELL" == "/bin/zsh" ]]; then
    savefuncs ~/.zshenv
else
    savefuncs ~/.bashrc
fi

# Realiza o curl para obter os templates.
printf "3/3 📄 Baixando templates de C/C++..."
curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-compilation-tools/main/templates/template.c >>~/.template.c
curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-compilation-tools/main/templates/template.cpp >>~/.template.cpp
printf " Feito!\n\n"

# Verifica se os comandos foram carregados com o "source".
if ! command -v chelp &>/dev/null; then
    abort "🎉 Configuração feita! Para começar a utilizar, feche este shell, abra-o novamente e rode ${LIGHTBLUE}chelp${NOCOLOR}."
fi

# Aguarda input do usuário para mostrar novos comandos.
printf "🎉 Configuração feita! Aperte ${TTYBOLD}ENTER${TTYRESET} para visualizar os novos comandos.\n"
read

# Mostra novos comandos.
chelp
printf "Para visualizar este menu novamente, é só digitar ${LIGHTBLUE}chelp${NOCOLOR} 😉\n\n"
