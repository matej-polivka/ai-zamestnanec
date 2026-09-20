#!/usr/bin/env bash
# Večerní extrakce paměti: projde, co si uživatel a asistent psali za posledních 24 h,
# a trvalé věci zapíše do memory/ podle memory/CLAUDE-WIKI.md. Spouští cron ve 23:00.
export BUN_INSTALL="$HOME/.bun"; export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"
MEM="${MEM:-memory}"
D="$HOME/.claude/projects/$(pwd | sed 's#/#-#g')"
SINCE=$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -u -v-24H +%Y-%m-%dT%H:%M:%S)
OUT=/tmp/pamet-den.txt
for f in "$D"/*.jsonl; do
  [ -f "$f" ] || continue
  jq -r --arg s "$SINCE" 'select((.type=="user" or .type=="assistant") and .timestamp > $s)
    | .type + ": " + (.message.content | if type=="string" then . else (map(select(.type=="text")|.text)|join(" ")) end)' "$f" 2>/dev/null
done | grep -v '^\(user\|assistant\): *$' | grep -v '<channel\|<system-reminder\|<task-notification' > "$OUT"
[ -s "$OUT" ] || exit 0
claude -p "Přečti soubor $OUT (konverzace za posledních 24 h) a podle pravidel v $MEM/CLAUDE-WIKI.md zapiš do $MEM/ všechno trvalé: nové lidi, projekty, termíny, rozhodnutí, preference, pravidla, co je spam. Aktualizuj existující záznamy, nepřidávej duplikáty. Ke každému zápisu přidej řádek do $MEM/log.md. Když není nic trvalého, nic nezapisuj. Na konci vypiš jen jednu větu, co jsi zapsal." \
  --permission-mode bypassPermissions --permission-prompts none >/dev/null 2>&1
rm -f "$OUT"
