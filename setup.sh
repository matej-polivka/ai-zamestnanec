#!/usr/bin/env bash
# cr8-asistent: jeden příkaz, který na čistém Hostinger VPS (Ubuntu 24.04) postaví AI zaměstnance
# dostupného přes Telegram, s ranním reportem v 7:00. Běží z tvého Claude předplatného (Pro/Max).
#
#   curl -fsSL https://raw.githubusercontent.com/matej-polivka/ai-zamestnanec/main/setup.sh | bash
#
# Spouští se jako root, ale asistent běží pod vlastním uživatelem "asistent"
# (Claude Code odmítá bezobslužný režim pod rootem, a je to tak i bezpečnější).
set -euo pipefail

REPO="https://github.com/matej-polivka/ai-zamestnanec"
U=asistent
H=/home/$U
APP=$H/asistent
# Terminál pro otázky; bez terminálu (Docker, CI) jen výpis na stderr a odpovědi z env.
if { : <>/dev/tty; } 2>/dev/null; then TTY=/dev/tty; else TTY=/dev/stderr; fi

say() { printf '\n\033[1;32m%s\033[0m\n' "$*" >$TTY; }
# Neinteraktivní režim (test / pokročilí): JMENO, TG_TOKEN, TG_ID jako env proměnné.
ask() { local v; [ "$TTY" = /dev/tty ] || { echo ""; return; }; printf '\033[1;33m%s\033[0m ' "$1" >$TTY; read -r v <$TTY; echo "$v"; }
asu() { su - $U -c "export PATH=$H/.bun/bin:\$PATH; $*"; }

[ "$(id -u)" = 0 ] || { echo "Spusť jako root."; exit 1; }

say "1/5  Instaluju nástroje (tmux, git, jq, unzip, bun, Claude Code)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq && apt-get install -y -qq tmux git jq curl unzip cron ca-certificates >/dev/null
id $U >/dev/null 2>&1 || useradd -m -s /bin/bash $U
if ! command -v claude >/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1
  install -m 755 "$HOME/.local/bin/claude" /usr/local/bin/claude
fi
[ -x $H/.bun/bin/bun ] || asu 'curl -fsSL https://bun.sh/install | bash >/dev/null 2>&1'
grep -q BUN_INSTALL $H/.bashrc || printf '\nexport BUN_INSTALL="$HOME/.bun"\nexport PATH="$BUN_INSTALL/bin:$PATH"\n' >> $H/.bashrc

say "2/5  Stahuju šablonu asistenta"
if   [ -d "$APP/.git" ];    then asu "git -C $APP pull -q --rebase --autostash" >/dev/null 2>&1 || echo "  (aktualizace šablony přeskočena, ponechávám tvoje úpravy)" >$TTY
elif [ -f "$APP/CLAUDE.md" ]; then echo "  (už je tady, nechávám)" >$TTY
else asu "git clone -q $REPO $APP"; fi
chmod +x $APP/*.sh
mkdir -p $H/.claude/channels/telegram

say "3/5  Jméno"
JMENO=${JMENO:-$(ask "  Jak se má tvůj asistent jmenovat? (Enter = Alan)")}; JMENO=${JMENO:-Alan}
sed -i "s/Jmenuješ se \*\*[^*]*\*\*/Jmenuješ se **$JMENO**/" $APP/CLAUDE.md

say "4/5  Telegram"
echo "  a) V Telegramu otevři @BotFather, pošli /newbot, pojmenuj ho. Dostaneš token (123456789:AAH...)." >$TTY
while :; do
  TOKEN=${TG_TOKEN:-$(ask "  Vlož token:")}
  BOTNAME=$(curl -s "https://api.telegram.org/bot$TOKEN/getMe" | jq -r '.result.username // empty')
  [ -n "$BOTNAME" ] && { echo "  ✓ bot @$BOTNAME" >$TTY; break; }
  echo "  ✗ Tenhle token Telegram nezná. Zkopíruj ho celý (včetně čísla a dvojtečky) a zkus znovu." >$TTY; unset TG_TOKEN
done
echo "  b) Otevři @userinfobot a napiš mu cokoliv. Odpoví ti tvým číselným ID." >$TTY
while :; do
  TGID=${TG_ID:-$(ask "  Vlož svoje ID:")}
  [[ "$TGID" =~ ^[0-9]{5,15}$ ]] && break
  echo "  ✗ ID je jen číslo (třeba 123456789). Zkus znovu." >$TTY; unset TG_ID
done
printf 'TELEGRAM_BOT_TOKEN=%s\n' "$TOKEN" > $H/.claude/channels/telegram/.env
printf '{"dmPolicy":"allowlist","allowFrom":["%s"],"groups":{},"ackReaction":"👀","chunkMode":"newline"}\n' "$TGID" > $H/.claude/channels/telegram/access.json
printf 'TG_CHAT_ID=%s\n' "$TGID" > $APP/.env

say "5/5  Přihlášení ke Claude"
chown -R $U:$U $H
if asu "claude auth status 2>/dev/null | grep -q '\"loggedIn\": true'"; then
  echo "  ✓ už přihlášeno" >$TTY
else
  # Login běží v tmuxu, odkaz z něj vytáhneme jako čistý text (bez klikacích escape sekvencí,
  # které terminál v prohlížeči nezobrazí) a kód od uživatele do něj pošleme.
  asu "tmux kill-session -t login 2>/dev/null; tmux new-session -d -s login -x 250 -y 50 'cd $APP && claude auth login; sleep 5'"
  URL=""; for i in $(seq 1 30); do
    URL=$(asu "tmux capture-pane -p -t login -J" | tr -d '\r' | grep -o 'https://claude.com/[^ ]*' | head -1)
    [ -n "$URL" ] && break; sleep 1
  done
  if [ -z "$URL" ]; then echo "  ✗ Nepodařilo se získat přihlašovací odkaz. Spusť: su - $U -c 'claude auth login'" >$TTY; exit 1; fi
  echo "" >$TTY
  echo "  Otevři tenhle odkaz v prohlížeči a přihlas se svým Claude účtem (Pro nebo Max):" >$TTY
  echo "" >$TTY
  echo "  $URL" >$TTY
  echo "" >$TTY
  echo "  Po přihlášení ti stránka ukáže kód. Zkopíruj ho celý a vlož sem." >$TTY
  while :; do
    CODE=$(ask "  Vlož kód:")
    [ -n "$CODE" ] || { [ "$TTY" = /dev/tty ] || exit 1; continue; }
    asu "tmux send-keys -t login '$CODE' Enter"
    ok=0; for i in $(seq 1 20); do
      asu "claude auth status 2>/dev/null | grep -q '\"loggedIn\": true'" && { ok=1; break; }; sleep 1
    done
    [ $ok = 1 ] && { echo "  ✓ přihlášeno" >$TTY; break; }
    echo "  ✗ Kód nesedí nebo vypršel. Otevři odkaz znovu a vlož nový kód." >$TTY
    asu "tmux kill-session -t login 2>/dev/null; tmux new-session -d -s login -x 250 -y 50 'cd $APP && claude auth login; sleep 5'"; sleep 4
    URL=$(asu "tmux capture-pane -p -t login -J" | tr -d '\r' | grep -o 'https://claude.com/[^ ]*' | head -1); echo "  $URL" >$TTY
  done
  asu "tmux kill-session -t login 2>/dev/null; true"
fi
asu "claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1; claude plugin install telegram@claude-plugins-official >/dev/null 2>&1; true"

# Přeskočit úvodního průvodce (barvy, důvěra složce, potvrzení bezobslužného režimu)
asu "jq '.hasCompletedOnboarding=true | .theme=\"dark\" | .projects[\"$APP\"].hasTrustDialogAccepted=true' ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json"
asu "jq '.skipDangerousModePermissionPrompt=true' ~/.claude/settings.json > ~/.claude/settings.tmp 2>/dev/null && mv ~/.claude/settings.tmp ~/.claude/settings.json || echo '{\"skipDangerousModePermissionPrompt\":true}' > ~/.claude/settings.json"
chmod 600 $H/.claude/channels/telegram/.env $APP/.env; chown -R $U:$U $H

say "Spouštím asistenta a nastavuju budík"
asu "$APP/start.sh"
asu "( crontab -l 2>/dev/null | grep -v 'asistent/' ; \
  echo '@reboot sleep 20 && $APP/start.sh' ; \
  echo '*/5 * * * * $APP/start.sh' ; \
  echo '0 7 * * * $APP/rano.sh' ) | crontab -"

curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$TGID" --data-urlencode "text=Ahoj, tady $JMENO, tvůj nový AI zaměstnanec. Běžím na serveru a poslouchám. Napiš mi 'rano' a pošlu ti první report, nebo se mě zeptej na cokoliv." >/dev/null
say "HOTOVO. Koukni do Telegramu, $JMENO ti právě napsal. Odpověz mu."
echo "  Emaily a kalendář: připoj si je na claude.ai → Nastavení → Konektory (Gmail, Google Calendar). $JMENO je uvidí sám." >$TTY
echo "  Ranní report chodí v 7:00. Chceš ho hned? Napiš botovi 'rano'." >$TTY
echo "  Nastavení: $APP/CLAUDE.md (kdo jsi, pravidla). Upravit: nano $APP/CLAUDE.md" >$TTY
echo "  Nakouknout, co dělá: su - asistent -c 'tmux attach -t asistent'  (odejít: Ctrl+B, pak D)" >$TTY
