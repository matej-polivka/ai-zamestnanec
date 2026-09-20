---
name: rano
description: Ranní report do Telegramu. Nové emaily roztříděné, dnešní program z kalendáře, připomínky. Spouští se automaticky v 7:00 nebo na příkaz "rano" / "ranní report" / "co mám dneska".
---

# Ranní report

Cíl: jedna zpráva, kterou přečtu u snídaně na mobilu za 30 sekund a vím, co mě dneska čeká.

## Postup

1. **Emaily**: načti nepřečtené emaily od včerejšího reportu (nebo za posledních 24 h). Roztřiď podle pravidel ve skillu `emaily`. Do reportu jde jen kategorie Urgentní a K přečtení. Archivovat a Spam jen spočítej.
2. **Dnešek**: pokud je napojený kalendář, vypiš dnešní události s časem. Když není, sekci vynech.
3. **Připomínky**: pokud je v crontabu něco na dnešek (`crontab -l | grep -E 'pripominka|ukol'`), zmiň to.
4. **Návrh akcí**: ke každému urgentnímu emailu jedna věta, co navrhuješ.

## Formát zprávy do Telegramu

Bez markdown hlaviček. Přesně takhle:

```
☀️ Dobré ráno, [den] [D. M.]

📬 Emaily: [X] nových, [Y] důležitých
• [Odesílatel]: [o co jde, 1 věta] → [návrh]
• ...
([Z] newsletterů a notifikací přeskočeno)

📅 Dnes
• [čas] [událost]

⏰ Připomínky
• [čas] [text]

Odpověz "ano" a připravím navržené věci. Nebo mi napiš, co chceš jinak.
```

Když v nějaké sekci nic není, napiš "nic" (například "📅 Dnes: nic"). Prázdná sekce je informace.

## Pravidla

- Nic neposílej, neodesílej, nearchivuj. Jen report a návrhy.
- Když se něco nepovede načíst (email, faktury), napiš to do reportu jednou větou a pokračuj se zbytkem. Nikdy neskonči bez zprávy.
- Maximálně 10 řádků. Když je toho víc, dej top 5 a "a dalších X, napiš 'emaily' pro celý seznam".
- Prázdný den (nic důležitého, nic v kalendáři, žádná připomínka): pošli jen "☀️ Dobré ráno. Vše v klidu, nic na tebe nečeká." Krátká zpráva v prázdný den buduje důvěru, dlouhá ji ničí.
- Když uživatel řekne "tohle už neposílej" nebo "přidej do reportu X", zapiš to do `memory/pravidla.md` a od zítřka to platí.
