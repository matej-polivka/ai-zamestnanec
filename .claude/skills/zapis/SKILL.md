---
name: zapis
description: Cokoliv, co přijde do Telegramu jako fotka, PDF, dokument nebo přeposlaný dlouhý text (účtenka, faktura, vizitka, smlouva, dlouhá konverzace, poznámka), převede na strukturovaný zápis, uloží do memory/zapisky/ a odpoví shrnutím ve 3 větách. Spouští se automaticky, když přijde příloha, nebo na "zapiš si", "ulož", "co je v tom".
---

# Pošli mi to sem

Uživatel ti něco pošle a chce, abys to zpracoval, ne aby to musel přepisovat sám. Tvoje práce: přečíst, vytáhnout podstatné, uložit, odpovědět krátce.

## Co může přijít a co s tím

| Přijde | Uděláš |
|---|---|
| Fotka účtenky / faktury | vytáhni datum, dodavatele, částku, DPH, co bylo koupeno → přidej řádek do `memory/zapisky/vydaje.md` |
| PDF smlouvy, nabídky, dokumentu | 5 nejdůležitějších bodů, termíny, částky, co se po uživateli chce → `memory/zapisky/dokumenty.md` |
| Vizitka / kontakt | jméno, firma, telefon, email, kontext → `memory/klienti.md` |
| Přeposlaný dlouhý email nebo chat | co se řeší, kdo co slíbil, jaké termíny, co je na uživateli → shrnutí 3 věty + záznam do `memory/klienti.md` u té osoby |
| Poznámka / nápad ("zapiš si, že...") | `memory/zapisky/poznamky.md` s datem |

Fotky z Telegramu jsou stažené v `~/.claude/channels/telegram/inbox/`, cesta je v příchozí zprávě. Otevři je nástrojem Read. PDF taky.

## Odpověď (vždy přes reply)

Tři věty maximálně: co to bylo, co jsi si zapsal, jestli z toho něco plyne ("splatnost 30. 9., mám ti to připomenout?").

Příklad: "Účtenka Alza, 18. 9., 2 490 Kč s DPH, monitor. Zapsáno do výdajů. Za září máš zatím 6 účtenek za 14 320 Kč."

## Pravidla

- Když z fotky něco nepřečteš, napiš, co chybí, a nevymýšlej.
- Hlasovou zprávu přepsat neumíš. Odpověz: "Hlasovky zatím nepřepisuju, napiš mi to prosím textem."
- Každý soubor v `memory/zapisky/` má na začátku jednořádkový popis, k čemu je, a záznamy s datem.
