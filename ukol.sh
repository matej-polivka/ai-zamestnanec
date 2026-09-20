#!/usr/bin/env bash
# Spustí asistenta na pozadí se zadáním a výsledek pošle do Telegramu. Používá skill pripominky přes cron.
export BUN_INSTALL="$HOME/.bun"; export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"; set -a; . ./.env; . "$HOME/.claude/channels/telegram/.env"; set +a
OUT=$(claude -p "$* Odpověz POUZE hotovou zprávou pro Telegram, stručně, bez markdown hlaviček." --permission-mode bypassPermissions --permission-prompts none 2>/dev/null) || OUT="Úkol se nepovedl: $*"
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" -d "chat_id=${TG_CHAT_ID}" --data-urlencode "text=${OUT:0:4000}" >/dev/null
