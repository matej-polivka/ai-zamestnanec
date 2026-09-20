---
name: rano
description: Ranní report do Telegramu. Nové emaily roztříděné, faktury po splatnosti a blízko splatnosti, dnešní program. Spouští se automaticky v 7:00 nebo na příkaz "rano" / "ranní report" / "co mám dneska".
---

# Ranní report

Cíl: jedna zpráva, kterou přečtu u snídaně na mobilu za 30 sekund a vím, co mě dneska čeká.

## Postup

1. **Emaily**: načti nepřečtené emaily od včerejšího reportu (nebo za posledních 24 h). Roztřiď podle pravidel ve skillu `emaily`. Do reportu jde jen kategorie Urgentní a K přečtení. Archivovat a Spam jen spočítej.
2. **Faktury**: pokud je nastavené napojení na fakturaci (skill `splatnosti`), zjisti faktury po splatnosti a splatné do 7 dnů. Vydané i přijaté. Když napojení není, sekci vynech.
3. **Dnešek**: pokud je napojený kalendář, vypiš dnešní události s časem. Když není, sekci vynech.
4. **Návrh akcí**: ke každému urgentnímu emailu jedna věta, co navrhuješ. K fakturám po splatnosti: "mám připravit upomínku?"

## Formát zprávy do Telegramu

Bez markdown hlaviček. Přesně takhle:

```
☀️ Dobré ráno, [den] [D. M.]

📬 Emaily: [X] nových, [Y] důležitých
• [Odesílatel]: [o co jde, 1 věta] → [návrh]
• ...
([Z] newsletterů a notifikací přeskočeno)

💸 Faktury
• Po splatnosti: [Firma] [částka] Kč, [X] dní → mám připravit upomínku?
• Do 7 dnů splatné: [Firma] [částka] Kč ([datum])
• Mám zaplatit: [Firma] [částka] Kč do [datum]

📅 Dnes
• [čas] [událost]

Odpověz "ano" a připravím navržené věci. Nebo mi napiš, co chceš jinak.
```

Když v nějaké sekci nic není, napiš "nic" (například "💸 Faktury: nic"). Prázdná sekce je informace.

## Pravidla

- Nic neposílej, neodesílej, nearchivuj. Jen report a návrhy.
- Když se něco nepovede načíst (email, faktury), napiš to do reportu jednou větou a pokračuj se zbytkem. Nikdy neskonči bez zprávy.
- Maximálně 15 řádků. Když je toho víc, dej top 5 a "a dalších X, napiš 'emaily' pro celý seznam".
