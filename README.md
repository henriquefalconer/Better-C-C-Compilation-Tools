# Better C/C++ Tools 

Ferramentas de linha de comando para programação em C/C++ para Linux, macOS e Windows.

## Funcionalidades atuais

- Criar novos arquivos C/C++ com templates iniciais, à escolha do usuário
- Compilar e executar códigos em C/C++, sem precisar lembrar de comandos gigantes do `gcc` ou `g++`
- Utilizar funções inspiradas no `print` e `input` do Python como substitutos de `cout` e `cin`
- Gerar arquivos de classe rapidamente, automaticamente criando setters e getters para todos os seus atributos
- Comentar a função `main` do arquivo principal e criar um zip dos arquivos do projeto com apenas um comando

## Configuração inicial

### Linux

1. Instalar o compilador GCC com o comando `sudo apt update && sudo apt install build-essential`

### macOS

1. Dentro do **Terminal.app**, alterar o shell para zsh utilizando o comando `chsh -s /bin/zsh`
2. Fechar e abrir o terminal
3. Baixar o Xcode Command Line Tools com o comando `xcode-select --install`
4. Definir o **zsh** como o terminal padrão do VSCode
5. Fechar e abrir o VSCode

### Windows (com WSL)

1. Abrir o Powershell como administrador (selecionando a opção com o botão direito)
2. Apertando o botão direito, colar e rodar o comando `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart` (conforme escrito no [site oficial da Microsoft sobre a instalação do WSL](https://docs.microsoft.com/pt-br/windows/wsl/install-win10))
3. Abrir a Microsoft Store e instalar uma distribuição de Linux qualquer (Debian, por exemplo)
4. Reiniciar máquina para que as alterações surtam efeito
5. Pesquisando no menu Iniciar, abrir a distribuição instalada, esperar instalação final e seguir os passos descritos na janela (Obs.: quando forem pedidos usuário e senha, pode usar o mesmo usuário do seu computador e usar uma senha qualquer – mas lembre-se que você precisará de tal senha mais pra frente)
6. Em seguida, ainda na mesma janela, instalar comandos básicos do Linux com `sudo apt update && sudo apt install curl build-essential zip dos2unix` (inserindo a mesma senha definida no passo anterior)
7. Após o processo ser finalizado, abrir o VSCode e definir o **wsl** como o terminal padrão do editor
6. Fechar e abrir o VSCode

**Obs.:** Para alterar o terminal padrão do VSCode, [basta seguir estes passos](https://stackoverflow.com/a/45899693)

## Instalação

Rodar o seguinte comando no terminal do VSCode:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/install.sh)"
```
Em seguida, fechar e abrir o VSCode, e rodar `chelp` para verificar se foi instalado

<br/>

> **Dica:** já aproveite e rode `hidevscc` se esta for a pasta em que você criará seus arquivos C/C++.
