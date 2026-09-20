#!/usr/bin/env bash
# Ranní report: cron ho spustí v 7:00. Claude připraví zprávu, my ji pošleme do Telegramu.
# Posíláme přes Bot API sami (ne přes Claude), aby zpráva dorazila i když Claude tool nezavolá.
export BUN_INSTALL="$HOME/.bun"; export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"
set -a; . ./.env; . "$HOME/.claude/channels/telegram/.env"; set +a

OUT=$(claude -p "Spusť skill rano. Vypiš POUZE hotovou zprávu pro Telegram, nic před ní ani za ní." \
  --permission-mode bypassPermissions --permission-prompts none 2>/dev/null) \
  || OUT="☀️ Ranní report se nepovedl. Napiš mi 'rano' a zkusím to znovu."

# Telegram bere max 4096 znaků na zprávu
printf '%s' "$OUT" | fold -s -w 4000 | awk 'BEGIN{RS="";ORS="\n\n"}{print}' >/dev/null
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d "chat_id=${TG_CHAT_ID}" --data-urlencode "text=${OUT:0:4000}" >/dev/null
