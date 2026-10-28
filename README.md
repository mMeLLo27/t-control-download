# T-Control — instalar

<img src="https://raw.githubusercontent.com/mMeLLo27/t-control-download/main/t-control.png" alt="" width="96" align="right" />

Journal de trading que roda **no seu computador**. Você registra e importa as operações das corretoras (B3 pela XP/Profit, cripto e forex), vê o desempenho, os riscos e o imposto. Os dados e as chaves das corretoras ficam só na sua máquina. Não há conta nem nuvem, e o T-Control nunca envia ordens.

Este repositório tem só os **instaladores**.

## Instalar

| Sistema | Como instalar |
|---|---|
| **Windows** 10/11 | Baixe [**T-Control-Windows-Setup.exe**](https://github.com/mMeLLo27/t-control-download/releases/latest/download/T-Control-Windows-Setup.exe) e abra. |
| **macOS** (Apple Silicon e Intel) | Abra o **Terminal** e cole o comando abaixo. |
| **Linux** (x86_64) | Abra o **Terminal** e cole o comando abaixo. |

```bash
curl -fsSL https://raw.githubusercontent.com/mMeLLo27/t-control-download/main/instalar.sh | bash
```

O instalador:
- não pede senha de administrador;
- cria o **ícone do T-Control na área de trabalho** e no menu de aplicativos;
- abre o app no navegador.

Para fechar, use **Sair**, no fim do menu lateral, ou o ícone perto do relógio.

No Windows também dá para instalar por comando, no **PowerShell**:

```powershell
irm https://raw.githubusercontent.com/mMeLLo27/t-control-download/main/instalar.ps1 | iex
```

### XP (Profit Pro)

O T-Control traz as operações da XP de dois jeitos:

- **Sozinho, a cada 5 minutos (Linux e macOS):** o instalador cria o ícone **Profit (T-Control)**, que abre o Profit com a porta de leitura. Com o Profit aberto por esse ícone e a conta conectada, as operações entram sem você fazer nada. No macOS o recurso é novo: se não funcionar, use o relatório. O T-Control só lê: nunca envia ordem nem vê a sua senha.
- **Pelo relatório (Windows, e em qualquer sistema):**
  1. No Profit, abra o menu **Roteamento → Relatório de Performance**.
  2. Escolha a conta e o período, abra a aba **Operações** e clique em **Exportar** (gera um PDF).
  3. No T-Control, vá em **Corretoras → Listar Corretoras → XP · Profit Pro → Enviar relatório** e escolha o arquivo.

### Avisos de segurança na primeira vez

O T-Control não tem a assinatura paga da Microsoft nem da Apple, por isso os sistemas avisam:

- **Windows:** em "O Windows protegeu o computador", clique em **Mais informações → Executar assim mesmo**. Instalando pelo comando do PowerShell, o aviso não aparece.
- **macOS:** o comando do Terminal já libera o app. Se você baixar o `.dmg` pelo navegador ([Apple Silicon](https://github.com/mMeLLo27/t-control-download/releases/latest/download/T-Control-macOS-AppleSilicon.dmg) ou [Intel](https://github.com/mMeLLo27/t-control-download/releases/latest/download/T-Control-macOS-Intel.dmg)), vá em **Ajustes do Sistema → Privacidade e Segurança → Abrir Mesmo Assim**.

## Atualizar

Rode o mesmo instalador de novo: baixe o `.exe` outra vez ou cole o mesmo comando. As suas operações, configurações e chaves **não são apagadas**.

## Onde ficam os seus dados

| Sistema | Pasta |
|---|---|
| Windows | `%APPDATA%\T-Control` |
| macOS | `~/Library/Application Support/T-Control` |
| Linux | `~/.local/share/t-control` |

Para guardar uma cópia, use **Configurações → Backup** dentro do app.

## Desinstalar

- **Windows:** Configurações → Aplicativos → **T-Control** → Desinstalar.
- **macOS:** arraste o **T-Control** de Aplicativos para o Lixo e apague o atalho da mesa.
- **Linux:** no Terminal, rode `rm -rf ~/.local/opt/T-Control ~/.local/bin/t-control ~/.local/share/applications/t-control.desktop` e apague o atalho da área de trabalho.

Desinstalar não apaga os dados. Para apagar também os dados, remova a pasta indicada acima.

---

© T-Control. O código não é aberto; este repositório distribui só os programas de instalação.
