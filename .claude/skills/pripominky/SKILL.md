---
name: pripominky
description: Připomínky a opakované úkoly na čas. "Připomeň mi zítra v 9 zavolat Petrovi", "každý pátek v 16:00 mi připomeň fakturaci", "každé pondělí ráno mi pošli, co mě čeká tento týden". Nastaví budík (cron) a ve správný čas pošle zprávu do Telegramu, nebo spustí úkol.
---

# Připomínky a plánované úkoly

Umíš dvě věci:
1. **Připomínka**: v daný čas pošleš do Telegramu text. Bez přemýšlení, jen zpráva.
2. **Plánovaný úkol**: v daný čas se spustíš a něco uděláš (projdeš emaily, uděláš research, napíšeš souhrn) a výsledek pošleš do Telegramu.

## Jak to nastavit

Připomínka = řádek v crontabu, který volá `./pripomen.sh "text"`:
```bash
( crontab -l 2>/dev/null; echo "0 16 * * 5 $HOME/asistent/pripomen.sh 'Fakturace! Vystav faktury za tento týden.' # pripominka: fakturace" ) | crontab -
```

Plánovaný úkol = řádek, který volá `./ukol.sh "zadání"`:
```bash
( crontab -l 2>/dev/null; echo "0 8 * * 1 $HOME/asistent/ukol.sh 'Projdi kalendář na tento týden a pošli mi přehled, co mě čeká, s návrhem, na co se připravit.' # ukol: tydenni prehled" ) | crontab -
```

Formát cronu: `minuta hodina den měsíc den_v_týdnu` (0 = neděle, 1 = pondělí, 5 = pátek). Jednorázová připomínka: nastav konkrétní den a měsíc a na konec příkazu přidej `; crontab -l | grep -v 'pripominka: NAZEV' | crontab -`, aby se po odpálení smazala.

Čas serveru je UTC. Česko je UTC+2 v létě (do konce října), UTC+1 v zimě. "V 9 ráno" v létě = `0 7` v cronu. Vždy to přepočítej a v potvrzení napiš čas tak, jak ho řekl uživatel.

## Správa

- "co mám nastavené" → `crontab -l | grep -E 'pripominka|ukol'` a vypiš lidsky (název, kdy, co)
- "zruš připomínku fakturace" → `crontab -l | grep -v 'pripominka: fakturace' | crontab -`
- Každé připomínce dej na konec řádku `# pripominka: nazev` nebo `# ukol: nazev`, ať ji umíš najít a smazat.

## Potvrzení

Po nastavení pošli jednu větu: "Nastaveno: každý pátek v 16:00 ti napíšu 'Fakturace!'. Zrušíš to slovy 'zruš připomínku fakturace'."
