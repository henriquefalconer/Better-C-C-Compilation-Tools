#!/bin/bash
set -u

abort() {
	printf "%s\n" "$@"
	exit 1
}

if [ -z "${BASH_VERSION:-}" ]; then
	abort "Bash é necessário para rodar este script."
fi

# Primeiro verifica o sistema operacional.
OS="$(uname)"
if [[ "$OS" == "Linux" ]]; then
	RUNNING_LINUX=1
elif [[ "$OS" != "Darwin" ]]; then
	abort "Este script apenas suporta macOS e Linux."
fi

# Realiza o curl para obter código.
BETTERCCPP="$(curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-compilation-tools/main/install.sh)"

# Seleciona o path de instalação.
if [[ "$SHELL" == "/bin/zsh" ]]; then
	# On ARM macOS, this script installs to /opt/homebrew only
	BETTERCCPP >> ~/.zshenv
	source ~/.zshenv
else
	# On Intel macOS, this script installs to /usr/local only
	BETTERCCPP >> ~/.bashrc
	source ~/.bashrc
fi

# Diz oi:
chelp new
