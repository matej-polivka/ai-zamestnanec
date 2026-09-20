---
name: emaily
description: Projde nové emaily, roztřídí je do 4 kategorií (urgentní, k přečtení, archivovat, spam), navrhne odpovědi na urgentní a batch akce ke schválení. Spouští se na "emaily", "projdi emaily", "co mi přišlo".
---

# Třídění emailů

## Kategorie

- **Urgentní**: skutečný člověk nebo firma s konkrétním požadavkem, chce odpověď dnes, nebo má termín.
- **K přečtení**: byznys informace, faktury, dokumenty, nástroje, které používám. Nespěchá.
- **Archivovat**: newslettery, automatické notifikace, sociální sítě, "update" emaily.
- **Spam**: nevyžádaná reklama, podezřelé nabídky, marketing bez vztahu k mému byznysu.

Naučené preference odesílatelů jsou v `memory/emaily-preference.md`. Přečti je před tříděním. Když mi řekneš "tenhle odesílatel je vždy X", zapiš to tam.

## Postup

1. Načti nepřečtené emaily od posledního spuštění (datum je v `memory/emaily-preference.md`, sekce Poslední spuštění). Když tam nic není, posledních 48 hodin.
2. Každý zařaď. Pokud email obsahuje termín ("do pátku", "do zítřka"), vypiš ho a kolik dní zbývá.
3. K urgentním navrhni odpověď, 2 až 3 věty, v mém tónu (viz CLAUDE.md, sekce O mně).
4. Pošli přehled a jeden seznam navržených akcí. Čekej na jedno "ano".
5. Po "ano" proveď všechny akce najednou (archivace, označení spamu, vytvoření draftů). Draft nikdy neodesílej.
6. Zapiš aktuální datum a čas do Poslední spuštění.

## Formát pro Telegram

```
📬 Emaily [D. M.], od [čas posledního spuštění]

🔴 Urgentní ([X])
• [Odesílatel]: [o co jde] ⏰ [termín, za X dní]
  Návrh: [2 až 3 věty]

🟡 K přečtení ([X])
• [Odesílatel]: [o co jde]

📦 Archivovat ([X]): [odesílatelé oddělení čárkou]
🗑 Spam ([X]): [odesílatelé]

Napiš "ano" a archivuju, označím spam a připravím drafty odpovědí. Nebo upřesni.
```

## Pravidla

- Nikdy neodesílej email bez výslovného "pošli" k té konkrétní odpovědi.
- Nikdy nemaž. Archivace ano (po schválení), mazání ne.
- Když si nejsi jistý kategorií, dej K přečtení. Lepší přečíst navíc než přehlédnout.
