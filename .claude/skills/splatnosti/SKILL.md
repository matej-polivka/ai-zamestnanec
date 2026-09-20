---
name: splatnosti
description: Faktury po splatnosti a blízko splatnosti z Fakturoidu (vydané i přijaté). Připraví upomínku ke schválení. Spouští se na "splatnosti", "kdo mi dluží", "co mám zaplatit", "faktury".
---

# Splatnosti (Fakturoid)

Vyžaduje env proměnné `FAKTUROID_CLIENT_ID`, `FAKTUROID_CLIENT_SECRET`, `FAKTUROID_SLUG`, `FAKTUROID_EMAIL`
(nastavuje průvodce při instalaci, jsou v `.claude/settings.json`).
Když nejsou nastavené, řekni: "Fakturace není napojená. Ve Fakturoidu: Nastavení → Uživatelský účet → API. Pošli mi Client ID, Client Secret, slug účtu (z adresy app.fakturoid.cz/SLUG) a přihlašovací email."

## Autentizace

Každé volání musí mít hlavičky `Accept: application/json` a `User-Agent: Asistent (<email>)`, jinak API vrátí 415/403.

```bash
TOKEN=$(curl -s -X POST "https://app.fakturoid.cz/api/v3/oauth/token" \
  -u "${FAKTUROID_CLIENT_ID}:${FAKTUROID_CLIENT_SECRET}" \
  -H "Accept: application/json" -H "Content-Type: application/json" \
  -H "User-Agent: Asistent (${FAKTUROID_EMAIL})" \
  -d '{"grant_type":"client_credentials"}' | jq -r .access_token)
B="https://app.fakturoid.cz/api/v3/accounts/${FAKTUROID_SLUG}"
H=(-H "Accept: application/json" -H "Authorization: Bearer $TOKEN" -H "User-Agent: Asistent (${FAKTUROID_EMAIL})")
```

## Postup

1. Vydané po splatnosti: `curl -s "$B/invoices.json?status=overdue" "${H[@]}"`
2. Vydané otevřené (nezaplacené, ještě ve splatnosti): `curl -s "$B/invoices.json?status=open" "${H[@]}"`
3. Přijaté po splatnosti: `curl -s "$B/expenses.json?status=overdue" "${H[@]}"`
4. Přijaté otevřené: `curl -s "$B/expenses.json?status=open" "${H[@]}"`
5. Pole: `number`, `client_name` (u expenses `supplier_name`), `remaining_amount` (kolik zbývá zaplatit), `currency`, `due_on`. Dny po splatnosti = dnes minus `due_on`. Z otevřených vyber ty s `due_on` do 7 dnů.
6. Když je víc než jedna stránka (API vrací 40 na stránku), přidej `&page=2`.

## Formát pro Telegram

```
💸 Splatnosti [D. M.]

🔴 Dluží mi (po splatnosti)
• [Firma] [částka] [měna], faktura [číslo], [X] dní po splatnosti

🟡 Dluží mi (do 7 dnů)
• [Firma] [částka] [měna], splatné [datum]

📤 Mám zaplatit
• [Firma] [částka] [měna] do [datum] ([X] dní)

Celkem mi dluží [součet] Kč, já dlužím [součet] Kč.
Mám připravit upomínky na faktury po splatnosti? Napiš "ano".
```

Částky v cizí měně nech v té měně, do součtu je přepočti orientačně a označ "cca".

## Upomínka (po "ano")

Pro každou fakturu po splatnosti připrav text emailu: vykání, slušné, 4 věty, číslo faktury, částka, původní splatnost, prosba o úhradu nebo info o stavu. Ukaž mi texty. Odešlu já, nebo řeknu "pošli [firma]" a ty vytvoříš draft v emailu. Nikdy neodesílej sám. Nikdy nic ve Fakturoidu nevytvářej ani neměň.
