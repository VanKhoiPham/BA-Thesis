= Vergleichende Analyse

In diesem Kapitel werden die Ergebnisse der beiden Workflows ("Human First" vs. "AI First") systematisch verglichen und analysiert. Ziel ist es, nicht nur quantitative Unterschiede in Bezug auf Zeit und Codequalität aufzuzeigen, sondern auch qualitative Muster in den aufgetretenen Fehlern zu identifizieren und deren Ursachen zu ergründen.

== Quantitative Analyse

=== Zeitaufwand und Effizienz

Die folgende Tabelle fasst die gemessenen Metriken beider Workflows zusammen. Workflow 1 (WF1) bezeichnet den Ansatz "Human → AI Optimization", Workflow 2 (WF2) den Ansatz "AI → Human Debugging".

#figure(
  table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [*Metrik*], [*Workflow 1 (WF1)*], [*Workflow 2 (WF2)*], [*Differenz*]
    ),
    [Total LOC], [2.648], [4.950], [+87%],
    [Gen/Impl Zeit], [~48h], [~6h], [-88%],
    [Debug Zeit], [~2.5h], [~10.5h], [+320%],
    [Gesamtzeit], [~50.5h], [~16.5h], [-67%],
    [Anzahl Bugs], [5], [21], [+320%],
  ),
  caption: [Vergleich der Entwicklungsmetriken],
)

Diese quantitativen Unterschiede bilden die empirische Grundlage für die Beantwortung der Forschungsfrage, da sie den Trade-off zwischen Geschwindigkeit und Stabilität messbar machen.

*Beobachtung:* WF2 führte zu einer massiven Reduktion der Implementierungszeit (-88%), verlagerte jedoch den Aufwand signifikant in die Debugging-Phase (+320%). Die Gesamtzeitersparnis lag bei 67%, erkauft durch eine deutlich höhere Fehlerrate.

*Netto-Produktivität:* Eine kritische Betrachtung zeigt, dass der Zeitvorteil der KI nicht linear scaliert. Obwohl die Generierung (~6h) extrem schnell ist, steigt der Debugging-Aufwand überproportional an. Bei komplexeren Aufgaben, wo die Debug-Zeit die Generierungszeit um den Faktor 3 übersteigt, droht die Netto-Produktivität ins Negative zu kippen ("Negative Productivity Tipping Point"), insbesondere bei komplexen, domänenspezifischen Anforderungen. Dies geschieht, wenn die Kosten für das Beheben subtiler KI-Fehler die Einsparungen beim Schreiben des Boilerplate-Codes übersteigen.

=== Fehlerverteilung (Bug Distribution)

Die Analyse der Fehler zeigt unterschiedliche Schwerpunkte in den beiden Ansätzen:

#figure(
  table(
    columns: (auto, auto),
    inset: 10pt,
    table.header([*Kategorie*], [*Anteil*]),
    [Data & Persistence], [38% (Größte Kategorie)],
    [API & Contract], [19%],
    [Edge Cases], [24%],
    [Security], [5%],
    [Others], [14%],
  ),
  caption: [Verteilung der Fehlertypen],
)

-   *WF1:* Fehler waren auf wenige, komplexe Kategorien konzentriert.
-   *WF2:* Fehler waren über alle Kategorien verstreut (*Scatter-gun Effect* – breit gestreute Fehlertypen).

*Meta-Analyse:* Auffällig ist, dass über 60 % der Fehler in Workflow 2 systemübergreifende Kategorien betreffen (*Cross-Cutting Concerns* wie Data & Persistence, Security, API Contracts), während lokale Logikfehler seltener sind. Dies deutet darauf hin, dass die KI sehr stark in der Erzeugung isolierter Code-Einheiten ("Local Optimization") ist, aber Schwächen beim Verständnis globaler Zusammenhänge und impliziter Systemregeln aufweist.

=== Codequalität (Quality Scores)

Die Bewertung der Codequalität (Skala 1-5) zeigt ebenfalls klare Unterschiede:

-   *WF1 Overall Score: 4.4/5*
-   *WF2 Overall Score: 3.3/5*

Während WF2 im Bereich *Readability* (Lesbarkeit) gut abschnitt, lagen die Werte für *Robustness* und *Security* deutlich unter denen von WF1.

== Qualitative Analyse

=== Katalog der Fehlermuster (Bug Pattern Catalog)

Es wurden wesentliche wiederkehrende Fehlermuster im KI-generierten Code identifiziert:

1.  *Pattern 1: Data & Persistence (8 Bugs)*
    - *Symptome:* `LazyInitializationException`, fehlende `@Transactional` Annotationen, falsches Session-Handling.
    - *Grund:* Die KI modelliert oft nur die statische Struktur, versteht aber nicht den Lebenszyklus von Hibernate-Entities zur Laufzeit.

2.  *Pattern 2: API Contract (4 Bugs)*
    - *Symptome:* Feld-Unstimmigkeiten zwischen Frontend und Backend (z.B. `isActive` vs `active`).
    - *Grund:* Die KI generierte Frontend und Backend oft isoliert ohne Kenntnis des gegenseitigen Vertrages (Contract).

3.  *Pattern 3: Edge Cases (5 Bugs)*
    - *Symptome:* Fehlende Null-Checks, mangelnde Validierung von Input-Grenzwerten.
    - *Grund:* KI-Modelle fokussieren stark auf den "Happy Path" (*Normalfall ohne Randbedingungen*) und vernachlässigen Randfälle.

4.  *Pattern 4: Security (1 Kritischer Bug)*
    - *Symptome:* Fehlende `@RolesAllowed` Annotationen an Endpunkten.
    - *Grund:* Sicherheitsanforderungen waren im Prompt nicht explizit genug ("Security by Default" ist keine inhärente Eigenschaft aktueller LLMs ohne explizite sicherheitsbezogene Vorgaben im Prompt).

    - *Grund:* Sicherheitsanforderungen waren im Prompt nicht explizit genug ("Security by Default" ist keine inhärente Eigenschaft aktueller LLMs ohne explizite sicherheitsbezogene Vorgaben im Prompt).

=== Ursachenanalyse (Root Cause Analysis)

Die Ursachen für die hohe Fehlerrate in Workflow 2 lassen sich in technische, prozessuale und systemische Faktoren unterteilen.

==== Technische Ursachen
1.  *Halluzination von Bibliotheken:* Die KI importierte teilweise existierende, aber inkompatible oder veraltete Bibliotheksversionen.
2.  *Mangelnde Laufzeit-Semantik:* Das Modell versteht Syntax (Code-Struktur) perfekt, aber Semantik (Laufzeitverhalten, Transaktionen, Timing) nur eingeschränkt.

==== Prozessuale Ursachen (Input & Kontext)
Ein wesentlicher Faktor für Fehler in Workflow 2 war der Mangel an präzisem Kontext im Prompting-Prozess:

1.  *Fehlende API-Spezifikationen:* Der KI wurden oft generische Anweisungen gegeben ("Erstelle ein CRUD für User") ohne explizite Definition der JSON-Formate für Request und Response. Dies führte dazu, dass die KI Datenstrukturen "erfand", die nicht mit dem restlichen System kompatibel waren.
2.  *Kontext-Fenster & Gedächtnis (Memory Retention):* Mit zunehmender Projektdauer verlor die KI relevante Informationen aus früheren Interaktionen. Da nicht der gesamte Codebase-Kontext bei jeder Anfrage erneut übermittelt werden konnte, "vergaß" die KI etablierte Muster oder zuvor definierte Constraints, was zu Inkonsistenzen führte (z.B. plötzlicher Wechsel der Namenskonventionen).

==== Systemische Ursachen
1.  *Fehlender Architektur-Kontext:* Der KI fehlt oft der Überblick über die Gesamtarchitektur. Sie optimiert lokal (eine Datei), was global (im Gesamtsystem) zu Problemen führen kann.

==== Strukturelle Ursachen (Systemic Causes)
Die Unterschiede zwischen den Workflows lassen sich nicht allein durch die Anzahl der Codezeilen erklären, sondern sind auf fundamentale strukturelle Unterschiede zurückzuführen:

1.  *Kontext-Verfügbarkeit (Context Availability):*
    - *Workflow 1:* Der menschliche Entwickler arbeitet mit vollem impliziten Wissen über das Gesamtsystem, die Architekturhistorie und nicht-funktionale Anforderungen.
    - *Workflow 2:* Die KI muss die Architektur oft "halluzinieren" oder raten, da ihr der vollständige Kontext fehlt. Dies führt dazu, dass sie Lösungen generiert, die lokal korrekt aussehen, aber architektonisch inkonsistent sind (z.B. Verletzung von Schichtengrenzen).

2.  *Cost of Change (Kosten der Änderung):*
    Eine Änderung in WF1 ist teuer in der Implementierung, aber günstig im Debugging. In WF2 sind Änderungen "billig" zu generieren, erzeugen aber oft potenziell *Technical Debt*, dessen Zinsen in Form von erhöhtem Debugging-Aufwand sofort fällig werden.

=== Vergleich der Workflows

   *WF1 (Human First):*
       *Stärken:* Hohe Qualität, Sicherheit, Robustheit bei Edge Cases.
       *Schwächen:* Langsame Entwicklungsgeschwindigkeit, anfällig für "Accidental Complexity" (Konfigurationsfehler).

   *WF2 (AI First):*
      *Stärken:* Extrem hohe Geschwindigkeit beim Prototyping, gute Lesbarkeit, eliminiert Boilerplate-Code.
       *Schwächen:* Hohe Bug-Dichte, Sicherheitslücken, Performance-Probleme, erfordert intensives Review.

==== Risikoprofil und Verlässlichkeit
Vergleicht man die Risikostruktur beider Ansätze, ergibt sich ein klares Bild:
- *Workflow 1* weist ein *niedriges, planbares Risiko* auf. Fehler entstehen meist durch menschliche Unachtsamkeit, bleiben aber oft lokal begrenzt.
- *Workflow 2* zeigt eine *hohe Varianz* und kritische "Ausreißer" im Risikoprofil. Während einfache Aufgaben perfekt gelöst werden, können bei komplexen Anforderungen gravierende Sicherheitslücken (z.B. fehlende Autorisierung) entstehen. Das Risiko ist hier *weniger vorhersehbar*, was den Review-Aufwand für sicherheitskritische Komponenten massiv erhöht.

Zusammenfassend lässt sich festhalten, dass der Unterschied zwischen WF1 und WF2 weniger ein technologischer als vielmehr ein epistemischer ist: Während WF1 auf implizitem Expertenwissen basiert, operiert WF2 auf statistischen Wahrscheinlichkeiten ohne echtes Systemverständnis.

== Lösungsstrategien

Die folgenden Lösungsstrategien ergeben sich direkt aus den zuvor identifizierten Fehlermustern und dienen als praxisorientierte Ableitung der Analyseergebnisse.

Um die Schwächen von Workflow 2 zu mitigieren, wurden folgende Strategien entwickelt:

1.  *Contract-First Prompting:* Definition von Schnittstellen (API-Contracts, Interfaces) *vor* der eigentlichen Code-Generierung. Die KI muss sich an diese strikten Vorgaben halten.
2.  *Constraint-Based Prompting:* Explizites Mitgeben von Constraints (z.B. "Nutze immer `@Transactional` für Schreibvorgänge", "Keine statischen Methoden").
3.  *Iterative Refinement:* Statt riesige Code-Blöcke auf einmal zu generieren, sollte der Code iterativ in kleineren, überprüfbaren Schritten aufgebaut werden.
4.  *Security Checklist:* Eine explizite Checkliste für Sicherheitsanforderungen, die als Teil des Prompts oder des Review-Prozesses dient.
5.  *Hybrid Workflow:* Der ideale Ansatz kombiniert die Geschwindigkeit von WF2 für Boilerplate/Prototyping mit der Sorgfalt von WF1 für kritische Kernlogik und Sicherheitskomponenten.

== Zusammenfassung und Entscheidungshilfe

Die Analyse zeigt, dass keiner der beiden Workflows universell überlegen ist. Die Wahl hängt von den Projektanforderungen ab:

- *Wann Workflow 1?* Für kritische Infrastruktur, Sicherheitskomponenten, komplexe Geschäftslogik und langlebige Systeme, bei denen Wartbarkeit vor Geschwindigkeit geht.
- *Wann Workflow 2?* Für Prototyping, MVPs, interne Tools, CRUD-Anwendungen und Boilerplate-Code, wo Time-to-Market entscheidend ist.

Die effektivste Methode ist oft ein *hybrider Ansatz*, bei dem KI als Beschleuniger für Standardaufgaben dient, während erfahrene Entwickler die Architekturverantwortung und Qualitätssicherung behalten.
