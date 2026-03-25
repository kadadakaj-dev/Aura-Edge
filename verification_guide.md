# Návod na overenie AOD a Perzistencie

Tento návod vám pomôže otestovať nové funkcie **Always-On Display (AOD)** a **Infinite Persistence** na vašom fyzickom zariadení.

### 1. Prvotné nastavenie (Dashboard)
1.  Otvorte aplikáciu AuraEdge.
2.  Na karte **Dashboard** by ste mali vidieť červený panel s upozornením na oprávnenia.
3.  Kliknite na **"Povoliť zobrazenie nad aplikáciami"** a povoľte AuraEdge v nastaveniach systému.
4.  Kliknite na **"Vypnúť optimalizáciu batérie"** a v systéme vyberte "Nepoužívať optimalizáciu" (Allow).
5.  Keď zmizne červený panel, AuraEdge je pripravená na "nekonečný" beh.

### 2. Testovanie Snake Fyziky (Studio)
1.  Prejdite na kartu **Studio**.
2.  Kliknite na sekciu **Snake**.
3.  Vyskúšajte tri režimy:
    *   **Slučka**: Plynulý nekonečný pohyb.
    *   **Ping-Pong**: Had sa odráža od koncov s novým efektom "Blesk pri náraze" (biely záblesk okraja).
    *   **Turbo**: Had postupne zrýchľuje až po reset cyklu.
4.  Všimnite si nový **"Motion Trail"** – had za sebou zanecháva jemne miznúci pruh.

### 3. Testovanie AOD (Zhasnutá obrazovka)
1.  V Studio zapnite prepínač **"Vždy zapnutý displej"**.
2.  Stlačte tlačidlo Power na telefóne (zhasnite obrazovku).
3.  **Výsledok**: Mal by sa zobraziť úplne čierny displej s aktívnym svetelným efektom (AOD).
4.  **Ukončenie AOD**: Dvakrát rýchlo klepnite (Double-Tap) kdekoľvek na čiernu plochu.
5.  AOD by sa malo zatvoriť a odhaliť vašu systémovú uzamykaciu obrazovku.

### 4. Testovanie hovorov
1.  Nechajte AOD aktívne.
2.  Požiadajte niekoho, aby vám zavolal.
3.  **Výsledok**: AuraEdge by NEMALA prekryť prichádzajúci hovor. AOD ostane neaktívne, kým nebude tlf. linka voľná.

### 5. Reštart zariadenia
1.  Reštartujte telefón.
2.  Počkajte cca 30-60 sekúnd po nabehnutí systému.
3.  Služba AuraEdge by sa mala automaticky spustiť v pozadí (uvidíte notifikáciu).
