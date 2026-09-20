# AI zaměstnanec do 10 minut

Vlastní AI asistent, který běží pořád (i když máš vypnutý počítač), píšeš mu z mobilu přes Telegram
a každé ráno v 7:00 ti pošle, co tě čeká: roztříděné emaily, dnešní program, připomínky.

Postavený na Claude Code. Žádný Docker, žádné configy. Jeden příkaz, dvě přihlášení.

## Co potřebuješ

- Claude předplatné (Pro nebo Max). Asistent jede z něj, nic dalšího neplatíš.
- Server, který nikdy nespí. Hostinger VPS KVM 2 s template "Ubuntu 24.04 with Claude Code": [hostinger.com/cr8](https://hostinger.com/cr8), kód `CR8` dá 10 % slevu.
- Telegram na mobilu.

## 5 kroků


1. **Kup VPS** přes odkaz výše. Při výběru operačního systému zvol **Ubuntu 24.04 with Claude Code**.
2. **Otevři terminál v prohlížeči.** V hPanelu u svého VPS klikni na "Terminál" (Browser terminal). Nic neinstaluješ.
3. **Vlož tento příkaz** a dej Enter:
   ```
   curl -fsSL https://raw.githubusercontent.com/matej-polivka/ai-zamestnanec/main/setup.sh | bash
   ```
4. **Odpověz průvodci na 3 věci:**
   - token bota z [@BotFather](https://t.me/BotFather) (pošli mu `/newbot`)
   - svoje Telegram ID z [@userinfobot](https://t.me/userinfobot) (napiš mu cokoliv)
   - přihlášení ke Claude: otevři odkaz, přihlas se, vlož kód zpátky
5. **Napiš svému botovi "ahoj".** Hotovo.

## Co asistent umí hned

| Napiš mu | Udělá |
|---|---|
| `rano` nebo `co mám dneska` | ranní report (chodí sám v 7:00) |
| `emaily` | roztřídí nové emaily, navrhne odpovědi, čeká na "ano" |
| `připomeň mi zítra v 9 zavolat Petrovi` | nastaví budík a v 9:00 ti napíše |
| `každé pondělí v 8 mi pošli, co mě čeká tento týden` | plánovaný úkol, každé pondělí přijde přehled |
| pošleš fotku účtenky nebo PDF | přečte, zapíše výdaj nebo shrnutí, odpoví 3 větami |
| cokoliv lidsky | "co psal Milan", "odpověz mu, že to pošlu v pátek", "zapamatuj si, že newslettery od X jsou spam" |

## Bezpečnost, jak je nastavená

- Bot odpovídá jen tobě (tvoje Telegram ID v allowlistu). Cizí zprávy zahazuje bez odpovědi.
- Asistent **nesmí odeslat email ani smazat email**. Je to zakázané v `.claude/settings.json`, ne jen "poprošené" v promptu.
- Všechno, co mění svět, ti nejdřív ukáže a čeká na "ano".
- Server je jen jeho. Nedávej tam nic jiného, co nechceš, aby viděl.

## Co zkusit první den

1. Napiš mu "rano". Dostaneš první report.
2. Napiš "emaily" a pak "ano". Uklidí ti schránku a připraví odpovědi.
3. Vyfoť účtenku a pošli mu ji. Zapíše ji a řekne, kolik jsi tento měsíc utratil.
4. Napiš "každý pátek v 16 mi připomeň fakturaci". Od teď to hlídá on.
5. Napiš "zapamatuj si, že newslettery od X jsou spam". Příště je nebude ukazovat.

## Přizpůsobení

- `CLAUDE.md`: jméno, kdo jsi, co je pro tebe urgentní, pravidla. Tady začni.
- `memory/`: co si asistent pamatuje. Můžeš tam psát i ty.
- `.claude/skills/`: co umí. Zkopíruj `rano/SKILL.md`, přejmenuj, popiš nový úkol.
- Čas ranního reportu: `crontab -e`, řádek s `rano.sh` (7 = sedm ráno, čas serveru).

## Když něco nejde

- **Bot neodpovídá:** v terminálu `tmux attach -t asistent` a podívej se, co píše. Odejít: `Ctrl+B`, pak `D`.
- **Neví o mých emailech:** zkontroluj claude.ai → Nastavení → Konektory, jestli je Gmail připojený. Pak napiš botovi "máš přístup k mým emailům?".
- **"Your login expires":** v tmuxu napiš `/login` a přihlas se znovu.
- **Chci to spustit znovu od nuly:** spusť příkaz z kroku 3 ještě jednou. Nic nerozbije, jen doplní.

## Pod kapotou (pro zvědavé)

Claude Code běží v `tmux` session s oficiálním Telegram pluginem. Cron ji každých 5 minut zkontroluje a po restartu serveru nastartuje.
Ranní report je `claude -p` spuštěný cronem, výsledek jde přes Telegram Bot API. Gmail a kalendář se propojí automaticky z tvého claude.ai účtu (claude.ai → Nastavení → Konektory).
