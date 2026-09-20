# Pravidla paměti (rulebook)

Tahle složka je dlouhodobá paměť asistenta. Chat je krátkodobá, tohle přežije restart i měsíce.

## Kam co patří
- `ja.md`: kdo je uživatel, čím se živí, co je pro něj urgentní, jak chce komunikovat.
- `lide.md`: klienti, kolegové, dodavatelé. Jeden člověk = jeden nadpis. Co spolu řešíme, poslední stav, datum.
- `projekty.md`: rozdělané věci, termíny, co je hotovo, co čeká. Jeden projekt = jeden nadpis.
- `pravidla.md`: co uživatel řekl, ať dělám jinak ("reporty bez emoji", "upomínky mírněji").
- `emaily-preference.md`: kdo je vždy spam / archivovat / urgentní.
- `zapisky/`: výdaje z účtenek, poznámky, shrnutí dokumentů (plní skill zapis).
- `log.md`: append-only, co se kdy do paměti zapsalo.

## Jak psát
1. Jedna informace = jedno místo. Když už existuje, aktualizuj, nepřidávej duplikát.
2. Piš datum ke všemu, co se může změnit ("stav 2026-09-20: čeká na smlouvu").
3. Krátce. Fakta, ne příběh. Za půl roku to musí dávat smysl bez kontextu chatu.
4. Když přepisuješ staré tvrzení, nech poznámku "(dříve X)".
5. Po každém zápisu přidej řádek do `log.md`: datum, soubor, co.
6. Nevymýšlej. Když něco nevíš (příjmení, částku), nech "TODO" a zeptej se.

## Kdy číst
Před úkolem, který se týká člověka, projektu nebo peněz, otevři `index.md` a pak jen soubor, který se hodí. Nečti všechno.

## Kdy psát
Hned, jakmile se dozvíš něco trvalého: nový klient, termín, rozhodnutí, preference, kdo je spam. Nečekej na večer. Večerní extrakce (`pamet.sh`) je jen záchranná síť, kdyby něco uteklo.
