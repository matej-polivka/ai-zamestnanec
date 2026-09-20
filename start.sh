#!/usr/bin/env bash
# Drží asistenta naživu. Volá ho cron každých 5 minut a po restartu serveru.
# Když session běží, nedělá nic. Když spadla, nastartuje ji znovu.
# ponytail: tmux + cron místo systemd. Stačí to a divák tomu rozumí.
export BUN_INSTALL="$HOME/.bun"; export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"
tmux has-session -t asistent 2>/dev/null && exit 0
tmux new-session -d -s asistent -c "$PWD" \
  "claude --continue --channels plugin:telegram@claude-plugins-official --permission-mode bypassPermissions || claude --channels plugin:telegram@claude-plugins-official --permission-mode bypassPermissions; sleep 30"
