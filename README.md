# Better C/C++ Tools 

Ferramentas de linha de comando para programação em C/C++ para Linux, macOS e Windows.

## Funcionalidades atuais

- Criar novos arquivos C/C++ com templates iniciais, à escolha do usuário
- Compilar e executar códigos em C/C++ no VSCode, sem precisar lembrar de comandos gigantes do `gcc` ou `g++`
- Comentar a função `main` do arquivo principal e criar um zip dos arquivos do projeto com apenas um comando

## Configuração inicial

<details>
<summary>Linux</summary>
<p>

1. Instale o compilador GCC com o comando `sudo apt update && sudo apt install build-essential`

</p>
</details>

<details>
<summary>macOS</summary>
<p>

1. Dentro do **Terminal.app**, altere o shell para zsh utilizando o comando `chsh -s /bin/zsh`
2. Feche e abra o terminal
3. Baixe o Xcode Command Line Tools com o comando `xcode-select --install`
4. Defina o **zsh** como o terminal padrão do VSCode ([siga estes passos](https://stackoverflow.com/a/45899693) caso tenha dúvidas de como fazer isso)
5. Feche e abra o VSCode

</p>
</details>

<details>
<summary>Windows (com WSL)</summary>
<p>

1. Abra o Powershell como administrador (selecionando a opção com o botão direito)
2. Apertando o botão direito, cole e rode o comando `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart` (conforme escrito no [site oficial da Microsoft sobre a instalação do WSL](https://docs.microsoft.com/pt-br/windows/wsl/install-win10))
3. Abra a Microsoft Store e instale uma distribuição de Linux qualquer (Debian, por exemplo)
4. Reinicie a máquina para que as alterações surtam efeito
5. Pesquisando no menu Iniciar, abra a distribuição instalada, espere a instalação final e siga os passos descritos na janela (Obs.: quando forem pedidos usuário e senha, pode usar o mesmo usuário do seu computador e usar uma senha qualquer – mas lembre-se que você precisará de tal senha mais pra frente)
6. Em seguida, ainda na mesma janela, instale comandos básicos do Linux com `sudo apt update && sudo apt install curl build-essential zip` (inserindo a mesma senha definida no passo anterior)
7. Após o processo ser finalizado, abra o VSCode e defina o **wsl** como o terminal padrão do editor (caso tenha dúvidas de como fazer isso, [siga estes passos](https://stackoverflow.com/a/45899693))
8. Feche e abra o VSCode (se, ao abrir, aparecerem mensagens no canto inferior direito, aceite-as e repita os passos 7 e 8)

</p>
</details>

## Instalação

Rode o seguinte comando no terminal do VSCode:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/henriquefalconer/better-c-cpp-tools/main/install.sh)"
```
Em seguida, feche e abra o VSCode, e rode `chelp` para verificar se foi instalado

<br/>

> **Dica:** Aproveite e já baixe a extensão **C/C++** da Microsoft na aba de extensões do VSCode para que o editor reconheça a linguagem que você está escrevendo.

## Como utilizar

1. Abra o VSCode na pasta onde você criará seus arquivos C/C++ e rode `hidevscc` para configurar o diretório (apenas necessário da primeira vez que você utiliza uma pasta)
2. Em seguida, rode `cppnew [nome do projeto]` para criar seu novo projeto
3. Rode `cd [nome do projeto]` para entrar na pasta do projeto criado
4. Faça as modificações necessárias no novo projeto
5. Rode `cpprun` para testar suas modificações
6. Repita os passos 4 e 5 até seu projeto estar finalizado

#### Por fim, para realizar a entrega do projeto:

- Caso o projeto contenha apenas um arquivo: comente a função main do arquivo e realize a entrega
- Caso o projeto contenha vários arquivos: rode `cppzip` para opcionalmente comentar a função `main` e criar automaticamente um zip de todos os arquivos `.h` e `.cpp` do projeto

#### E então, para criar um novo projeto:

1. Caso você esteja na pasta de algum projeto, rode `cd ..` para voltar ao diretório geral de projetos (ou feche e abra o VSCode)
2. E por fim, rode `cppnew [nome do projeto]` e `cd [nome do projeto]` novamente para criar e entrar no seu novo projeto
