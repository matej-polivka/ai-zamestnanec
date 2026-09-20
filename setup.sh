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
# Neinteraktivní režim (test / pokročilí): JMENO, TG_TOKEN, TG_ID, FAKTUROID_* jako env proměnné.
ask() { local v; printf '\033[1;33m%s\033[0m ' "$1" >$TTY; read -r v <$TTY; echo "$v"; }
asu() { su - $U -c "export PATH=$H/.bun/bin:\$PATH; $*"; }

[ "$(id -u)" = 0 ] || { echo "Spusť jako root."; exit 1; }

say "1/6  Instaluju nástroje (tmux, git, jq, unzip, bun, Claude Code)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq && apt-get install -y -qq tmux git jq curl unzip cron ca-certificates >/dev/null
id $U >/dev/null 2>&1 || useradd -m -s /bin/bash $U
if ! command -v claude >/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1
  install -m 755 "$HOME/.local/bin/claude" /usr/local/bin/claude
fi
[ -x $H/.bun/bin/bun ] || asu 'curl -fsSL https://bun.sh/install | bash >/dev/null 2>&1'
grep -q BUN_INSTALL $H/.bashrc || printf '\nexport BUN_INSTALL="$HOME/.bun"\nexport PATH="$BUN_INSTALL/bin:$PATH"\n' >> $H/.bashrc

say "2/6  Stahuju šablonu asistenta"
if   [ -d "$APP/.git" ];    then asu "git -C $APP pull -q"
elif [ -f "$APP/CLAUDE.md" ]; then echo "  (už je tady, nechávám)" >$TTY
else asu "git clone -q $REPO $APP"; fi
chmod +x $APP/*.sh
mkdir -p $H/.claude/channels/telegram

say "3/6  Jméno"
JMENO=${JMENO:-$(ask "  Jak se má tvůj asistent jmenovat? (Enter = Alan)")}; JMENO=${JMENO:-Alan}
sed -i "s/Jmenuješ se \*\*[^*]*\*\*/Jmenuješ se **$JMENO**/" $APP/CLAUDE.md

say "4/6  Telegram"
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

say "5/6  Fakturace (volitelné)"
echo "  Fakturoid: Nastavení → Uživatelský účet → API. Enter = přeskočit." >$TTY
FID=${FAKTUROID_CLIENT_ID:-$(ask "  Fakturoid Client ID:")}
if [ -n "$FID" ]; then
  FSEC=${FAKTUROID_CLIENT_SECRET:-$(ask "  Fakturoid Client Secret:")}
  FSLUG=${FAKTUROID_SLUG:-$(ask "  Slug účtu (z adresy app.fakturoid.cz/SLUG):")}
  FMAIL=${FAKTUROID_EMAIL:-$(ask "  Email, kterým se do Fakturoidu přihlašuješ:")}
  jq --arg a "$FID" --arg b "$FSEC" --arg c "$FSLUG" --arg d "$FMAIL" \
    '.env.FAKTUROID_CLIENT_ID=$a | .env.FAKTUROID_CLIENT_SECRET=$b | .env.FAKTUROID_SLUG=$c | .env.FAKTUROID_EMAIL=$d' \
    $APP/.claude/settings.json > $APP/.claude/settings.tmp && mv $APP/.claude/settings.tmp $APP/.claude/settings.json
fi

say "6/6  Přihlášení ke Claude"
echo "  Za chvíli uvidíš odkaz. Otevři ho v prohlížeči, přihlas se svým Claude účtem (Pro nebo Max)," >$TTY
echo "  zkopíruj kód, který ti prohlížeč ukáže, a vlož ho sem." >$TTY
chown -R $U:$U $H
if asu "claude auth status 2>/dev/null | grep -q '\"loggedIn\": true'"; then echo "  ✓ už přihlášeno" >$TTY
else su - $U -c "cd $APP && claude auth login" <$TTY >$TTY 2>&1; fi
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
echo "  Ranní report chodí v 7:00. Chceš ho hned? Napiš botovi 'rano'." >$TTY
echo "  Nastavení: $APP/CLAUDE.md (kdo jsi, pravidla). Upravit: nano $APP/CLAUDE.md" >$TTY
echo "  Nakouknout, co dělá: su - asistent -c 'tmux attach -t asistent'  (odejít: Ctrl+B, pak D)" >$TTY
