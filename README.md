# Better C/C++ Tools 

Ferramentas de linha de comando para programação em C/C++ para Linux, macOS e Windows.

## Funcionalidades atuais

- Criar novos arquivos C/C++ com templates iniciais, à escolha do usuário
- Compilar e executar códigos em C/C++, sem precisar lembrar de comandos gigantes do `gcc` ou `g++`
- Gerar arquivos de classe rapidamente, automaticamente criando setters e getters para todos os seus atributos
- Automaticamente adicionar atributos, métodos e importações faltantes de uma classe
- Comentar a função `main` do arquivo principal e criar um zip dos arquivos do projeto com apenas um comando

## Configuração inicial

### Linux

1. Instalar o compilador GCC com o comando `sudo apt install build-essential`

### macOS

1. Dentro do **Terminal.app**, alterar o shell para zsh utilizando o comando `chsh -s /bin/zsh`
2. Fechar e abrir o terminal
3. Baixar o Xcode Command Line Tools com o comando `xcode-select --install`
4. Definir o **zsh** como o terminal padrão do VSCode
5. Fechar e abrir o VSCode

### Windows

1. Baixar o [Git Bash](https://git-scm.com/download/win) (mesmo se já tiver, baixe-o novamente para atualizá-lo)
2. Instalar o compilador GCC [seguindo estes passos](https://dev.to/gamegods3/how-to-install-gcc-in-windows-10-the-easier-way-422j)
3. Baixar pacote de ferramentas GNU utilizando o [Gow (Gnu On Windows)](https://github.com/bmatzelle/gow/releases/download/v0.8.0/Gow-0.8.0.exe)
4. Definir o **Git Bash** como o terminal padrão do VSCode
5. Fechar e abrir o VSCode

**Obs.:** Para alterar o terminal padrão do VSCode, [basta seguir estes passos](https://stackoverflow.com/a/45899693)

## Instalação

Rodar o seguinte comando no terminal do VSCode:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/install.sh)"
```
Em seguida, fechar e abrir o VSCode, e rodar `chelp` para verificar se foi instalado

<br/>

> **Dica:** já aproveite e rode `hidevscc` se esta for a pasta em que você criará seus arquivos C/C++.
