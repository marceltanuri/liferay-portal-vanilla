# Liferay DXP - Sandbox de Desenvolvimento

Este projeto provisiona um ambiente de desenvolvimento completo e containerizado para o Liferay DXP, utilizando Docker e Docker Compose.

O objetivo principal é fornecer uma "sandbox" com uma stack do Liferay pronta para uso, simplificando o setup inicial e permitindo focar no desenvolvimento e teste de funcionalidades na plataforma. O ambiente inclui também um servidor mock de OAuth 2.0 para auxiliar em testes de integração de autenticação.

O `Makefile` automatiza todo o ciclo de vida do ambiente, desde a construção das imagens e aplicação de licenças até o encerramento e limpeza dos contêineres.

##  Pré-requisitos

Antes de começar, certifique-se de que você tem o `make` instalado em seu sistema. A maioria dos sistemas baseados em Unix (Linux, macOS) já o inclui. Você pode verificar executando:

```sh
make -v
```

## ⚠️ Configuração de Permissões

Para garantir o funcionamento correto da aplicação, é crucial conceder permissões de escrita em todos os diretórios e subdiretórios a partir da raiz deste projeto. Isso é necessário para evitar problemas com:

- **Arquivos de Log**: A aplicação precisa de permissão para criar e escrever em arquivos de log.
- **Deploy**: Processos de deploy podem precisar criar ou modificar arquivos.
- **Persistência de Dados**: Se a aplicação salva dados em arquivos locais (como bancos de dados SQLite, arquivos de sessão, etc.), ela precisará de permissão de escrita.

Execute o seguinte comando na raiz do projeto para conceder as permissões necessárias:

```sh
sudo chmod -R a+w .
```

> **Atenção**: Este comando concede permissão de escrita para todos os usuários em todos os arquivos e pastas. Em um ambiente de produção, considere usar permissões mais restritivas e específicas para os diretórios que realmente precisam, por questões de segurança.

## Como Usar o Makefile

Este projeto utiliza um `Makefile` para automatizar tarefas comuns de desenvolvimento e deploy. Para usar, navegue até o diretório raiz do projeto e execute os comandos `make` conforme descrito abaixo.

### Comandos Disponíveis

*   **`make up`**
    Este comando realiza as seguintes ações:
    1.  Verifica se o arquivo de licença `liferay/license/activation-key.xml` existe.
    2.  Se a variável `hotfix` for informada, faz o download do arquivo de hotfix correspondente.
    3.  Constrói as imagens Docker necessárias (`docker compose build`).
    4.  Inicia os contêineres em modo detached (`docker compose up -d`).
    
    > **Importante**: Antes de executar este comando, você **deve** colocar seu arquivo de licença DXP no diretório `liferay/license/` com o nome `activation-key.xml`. O contêiner do Liferay irá copiar este arquivo para o diretório de deploy durante a inicialização.
    
    **Uso Básico:**
    ```sh
    make up
    ```
    
    **Uso com Versão e Hotfix:**
    
    É possível especificar uma versão do Liferay (`v`) e um número de hotfix (`hotfix`). Ao fazer isso, o `Makefile` tentará baixar o hotfix automaticamente do CDN da Liferay e o colocará na pasta `liferay/patching` para ser aplicado durante a inicialização do contêiner.
    
    ```sh
    # Exemplo para usar a versão 2024.q2.8 com o hotfix 48
    make up v=2024.q2.8 hotfix=48
    ```

*   **`make down`**
    Para e remove os contêineres, redes e volumes associados ao projeto. Este comando também:
    - Remove as imagens Docker que foram construídas localmente (`--rmi local`).
    - Apaga os arquivos de hotfix (`.zip`) baixados na pasta `liferay/patching/`.
    
    Isso garante uma limpeza completa do ambiente.

    ```sh
    make down
    ```
