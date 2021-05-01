#!/bin/bash

abort() {
    printf "\n%s\n\n" "$@"
    exit 1
}

if [ -z "${BASH_VERSION:-}" ]; then
    abort "Bash é necessário para rodar este script."
fi

# Primeiro verifica o sistema operacional.
OS="$(uname)"
if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
    abort "Este script apenas suporta macOS e Linux."
fi

# String formatters
LIGHTBLUE='\e[94m'
PURPLE='\e[0;35m'
GREEN='\e[32m'
NOCOLOR='\e[0m'
TTYBOLD="\033[1;39m"
TTYRESET="\033[1;0m"

# Realiza o curl para obter código.
save() {
    printf "\n1/2 ⬇️  Baixando novos comandos de C/C++..."
    curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-compilation-tools/main/better_c_cpp.sh >>$1
    printf " Feito!\n\n"
    printf "2/2 📀 Salvando-os em ${LIGHTBLUE}$1${NOCOLOR}..."
    source $1
    printf " Salvo!\n\n"
}

# Seleciona o path de instalação.
if [[ "$SHELL" == "/bin/zsh" ]]; then
    save ~/.zshenv
else
    save ~/.bashrc
fi

# Aguarda input do usuário para mostrar novos comandos.
printf "🎉 Configuração feita! aperte ${TTYBOLD}ENTER${TTYRESET} para visualizar os novos comandos.\n"
read

# Mostra novos comandos.
chelp
printf "Para visualizar este menu novamente, é só digitar ${LIGHTBLUE}chelp${NOCOLOR} 😉\n\n"
