#!/usr/bin/env bash
# Pošle text do Telegramu. Používá skill pripominky přes cron.
cd "$(dirname "$0")"; set -a; . ./.env; . "$HOME/.claude/channels/telegram/.env"; set +a
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" -d "chat_id=${TG_CHAT_ID}" --data-urlencode "text=⏰ $*" >/dev/null
