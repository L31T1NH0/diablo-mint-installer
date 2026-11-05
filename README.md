# Diablo I no Linux Mint

Instalador automático do [DevilutionX](https://github.com/diasurgical/devilutionx) para Linux Mint/Ubuntu em computadores x86_64 (64 bits).

## Instalar

Baixe `instalador-diablo-mint.sh`, abra o terminal na pasta do arquivo e execute:

```bash
bash instalador-diablo-mint.sh
```

Execute como usuário normal. O próprio script pede a senha do sudo para instalar as dependências via apt. É necessária conexão com a internet.

O instalador baixa a versão portátil oficial mais recente do DevilutionX, baixa os dados de Diablo I, configura as bibliotecas e cria o atalho **Diablo (DevilutionX)** no menu. Em uma sessão gráfica, também tenta abrir o jogo ao terminar.

## Arquivos

- Jogo: `~/.local/share/devilutionx/`
- Dados, configurações e saves: `~/.local/share/diasurgical/devilution/`
- Dados principais: `~/.local/share/diasurgical/devilution/DIABDAT.MPQ`
- Lançador: `~/.local/bin/devilutionx`
- Atalho: `~/.local/share/applications/devilutionx.desktop`

Se `DIABDAT.MPQ` já existir e não estiver vazio, ele será mantido. Você pode copiar esse arquivo da sua instalação original antes de executar o script.

O download automático de `DIABDAT.MPQ` usa o servidor de terceiros `http://cdn.pvpgn.pro/diablo1/DIABDAT.MPQ`. O script verifica a assinatura MPQ e o tamanho mínimo; isso não autentica a origem nem verifica o conteúdo completo. Os arquivos do jogo não estão incluídos neste repositório. Consulte também as [instruções oficiais para obter os dados](https://devilutionx.com/mpq).

Hellfire e mods não são instalados. Este projeto não é afiliado à Blizzard nem ao DevilutionX.

## Validação

Sintaxe Bash e Python validada. Testes simulados cobrem instalação, reinstalação, diretórios com espaços, lançador, atalho e rejeição de download inválido. Ainda não validado em uma instalação real do Linux Mint.
