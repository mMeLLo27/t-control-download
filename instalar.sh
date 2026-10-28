#!/usr/bin/env bash
# Instala (ou atualiza) o T-Control no macOS ou no Linux com um comando só:
#
#   curl -fsSL https://raw.githubusercontent.com/mMeLLo27/t-control-download/main/instalar.sh | bash
#
# Baixa a última versão publicada no GitHub, instala na pasta do usuário (sem
# senha de administrador), cria o ícone na área de trabalho e abre o app.
# Os dados (operações, chaves) não são tocados numa atualização.
set -euo pipefail

REPO="mMeLLo27/t-control-download"  # repositório público só com os instaladores (o código é privado)
BASE="${TCONTROL_BASE:-https://github.com/$REPO/releases/latest/download}"  # TCONTROL_BASE: só para testar

say() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
fail() { printf '\n\033[1;31mErro:\033[0m %s\n' "$*" >&2; exit 1; }

TMP="$(mktemp -d)"
profit_note=""
trap 'rm -rf "$TMP"' EXIT

desktop_dir() {
  local dir
  dir="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
  [ -n "$dir" ] && [ "$dir" != "$HOME" ] && [ -d "$dir" ] && { echo "$dir"; return; }
  for dir in "$HOME/Desktop" "$HOME/Área de Trabalho" "$HOME/Área de trabalho"; do
    [ -d "$dir" ] && { echo "$dir"; return; }
  done
}

profit_app() {
  # "Profit (T-Control)" na mesa: abre o Profit com a porta de leitura do T-Control. Se ele já estiver aberto
  # sem a porta, pergunta se pode fechar e abrir de novo. Nunca derruba a instalação.
  cat > "$TMP/profit.applescript" <<'APPLESCRIPT'
set comPorta to (do shell script "curl -s -m 2 -o /dev/null http://127.0.0.1:9222/json/version && echo 1 || echo 0") is "1"
if comPorta then
	tell application "Profit" to activate
	return
end if
set aberto to (do shell script "pgrep -x Profit >/dev/null && echo 1 || echo 0") is "1"
if aberto then
	set escolha to button returned of (display dialog "O Profit está aberto sem a porta de leitura do T-Control, que lê as operações sozinho. Fechar e abrir de novo com a porta? Depois é só conectar a conta outra vez." buttons {"Deixar como está", "Fechar e abrir de novo"} default button 2 with title "Profit")
	if escolha is "Deixar como está" then return
	tell application "Profit" to quit
	repeat 20 times
		if (do shell script "pgrep -x Profit >/dev/null && echo 1 || echo 0") is "0" then exit repeat
		delay 0.5
	end repeat
end if
do shell script "open -a Profit --args --remote-debugging-port=9222"
APPLESCRIPT
  rm -rf "$desk/Profit (T-Control).app"
  if osacompile -o "$desk/Profit (T-Control).app" "$TMP/profit.applescript" 2>/dev/null; then
    icns="/Applications/Profit.app/Contents/Resources/$(defaults read /Applications/Profit.app/Contents/Info CFBundleIconFile 2>/dev/null || echo icon)"
    [ -f "$icns" ] || icns="$icns.icns"
    [ -f "$icns" ] && cp "$icns" "$desk/Profit (T-Control).app/Contents/Resources/applet.icns" 2>/dev/null || true
    profit_note=" Para a XP, abra o Profit pelo atalho \"Profit (T-Control)\" da mesa: as operações entram sozinhas."
  fi
}

install_mac() {
  case "$(uname -m)" in
    arm64) file="T-Control-macOS-AppleSilicon.dmg" ;;
    *) file="T-Control-macOS-Intel.dmg" ;;
  esac
  say "Baixando $file"
  curl -fL --progress-bar "$BASE/$file" -o "$TMP/$file" || fail "não consegui baixar $BASE/$file"

  for old in "/Applications/T-Control.app" "$HOME/Applications/T-Control.app"; do  # atualização: backup antes de trocar
    if [ -x "$old/Contents/MacOS/T-Control" ] && { [ -f "$old/Contents/Resources/backup-cli.txt" ] || [ -f "$old/Contents/Frameworks/backup-cli.txt" ]; }; then
      say "Fazendo o backup antes de atualizar"
      "$old/Contents/MacOS/T-Control" --backup antes-da-atualizacao || true
      break
    fi
  done

  say "Instalando em Aplicativos"
  pkill -x T-Control 2>/dev/null || true
  mount="$(hdiutil attach -nobrowse -readonly "$TMP/$file" | awk -F'\t' '/\/Volumes\//{print $NF; exit}')"
  [ -d "$mount/T-Control.app" ] || fail "o arquivo baixado não tem o T-Control.app"
  target="/Applications"
  [ -w "$target" ] || { target="$HOME/Applications"; mkdir -p "$target"; }
  rm -rf "$target/T-Control.app"
  ditto "$mount/T-Control.app" "$target/T-Control.app"
  hdiutil detach "$mount" -quiet || true
  xattr -dr com.apple.quarantine "$target/T-Control.app" 2>/dev/null || true  # app sem assinatura da Apple

  desk="$HOME/Desktop"
  if [ -d "$desk" ]; then
    rm -f "$desk/T-Control"
    ln -s "$target/T-Control.app" "$desk/T-Control"
  fi

  if [ -d /Applications/Profit.app ] && [ -d "$desk" ]; then
    profit_app  # Profit da XP instalado: atalho que o abre com a porta de leitura
  fi

  say "Abrindo o T-Control"
  open "$target/T-Control.app"
  echo "Pronto. O T-Control fica em $target e na área de trabalho; o ícone dele aparece na barra de menus, perto do relógio.$profit_note"
}

install_linux() {
  [ "$(uname -m)" = "x86_64" ] || fail "por enquanto o T-Control para Linux é só para processador x86_64 (Intel/AMD)."
  file="T-Control-Linux-x86_64.tar.gz"
  say "Baixando $file"
  curl -fL --progress-bar "$BASE/$file" -o "$TMP/$file" || fail "não consegui baixar $BASE/$file"

  say "Instalando na pasta do usuário"
  app="$HOME/.local/opt/T-Control"
  if [ -x "$app/T-Control" ] && [ -f "$app/_internal/backup-cli.txt" ]; then  # atualização: backup antes de trocar
    say "Fazendo o backup antes de atualizar"
    if command -v timeout >/dev/null; then timeout 300 "$app/T-Control" --backup antes-da-atualizacao || true
    else "$app/T-Control" --backup antes-da-atualizacao || true; fi
  fi
  pkill -f "$app/T-Control" 2>/dev/null || true
  rm -rf "$app"
  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/512x512/apps"
  tar -xzf "$TMP/$file" -C "$HOME/.local/opt"
  [ -x "$app/T-Control" ] || fail "o arquivo baixado não tem o T-Control"
  ln -sf "$app/T-Control" "$HOME/.local/bin/t-control"
  cp "$app/_internal/packaging/icons/t-control.png" "$HOME/.local/share/icons/hicolor/512x512/apps/t-control.png"

  entry="[Desktop Entry]
Type=Application
Name=T-Control
Comment=Journal de trading
Exec=$app/T-Control
Icon=t-control
Terminal=false
Categories=Office;Finance;
StartupNotify=false"
  printf '%s\n' "$entry" > "$HOME/.local/share/applications/t-control.desktop"
  command -v update-desktop-database >/dev/null && update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

  desk="$(desktop_dir || true)"
  if [ -n "$desk" ]; then
    printf '%s\n' "$entry" > "$desk/t-control.desktop"
    chmod +x "$desk/t-control.desktop"
    command -v gio >/dev/null && gio set "$desk/t-control.desktop" metadata::trusted true 2>/dev/null || true
  fi

  # Profit da XP instalado: ícone que o abre com a porta de leitura (coleta automática a cada 5 minutos)
  profit_note=""
  if [ -x /usr/lib/profit/Profit ] && [ -f "$app/_internal/scripts/linux/abrir-profit.sh" ]; then
    chmod +x "$app/_internal/scripts/linux/abrir-profit.sh"
    pentry="[Desktop Entry]
Type=Application
Name=Profit (T-Control)
Comment=Abre o Profit com a porta de leitura do T-Control
Exec=$app/_internal/scripts/linux/abrir-profit.sh
Icon=profit
Terminal=false
Categories=Office;Finance;
StartupNotify=true"
    printf '%s\n' "$pentry" > "$HOME/.local/share/applications/profit-tcontrol.desktop"
    if [ -n "$desk" ]; then
      printf '%s\n' "$pentry" > "$desk/profit-tcontrol.desktop"
      chmod +x "$desk/profit-tcontrol.desktop"
      command -v gio >/dev/null && gio set "$desk/profit-tcontrol.desktop" metadata::trusted true 2>/dev/null || true
    fi
    profit_note=" Para a XP, abra o Profit pelo ícone \"Profit (T-Control)\": as operações entram sozinhas."
  fi

  say "Abrindo o T-Control"
  nohup "$app/T-Control" >/dev/null 2>&1 &
  echo "Pronto. O T-Control está no menu de aplicativos${desk:+ e na área de trabalho}. Para abrir pelo terminal: t-control.$profit_note"
}

case "$(uname -s)" in
  Darwin) install_mac ;;
  Linux) install_linux ;;
  *) fail "sistema não suportado: $(uname -s). No Windows, use o instalador .exe." ;;
esac
