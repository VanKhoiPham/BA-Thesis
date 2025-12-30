= Diskussion

Ziel dieses Kapitels ist es, die in Kapitel 5 gewonnenen Analyseergebnisse in einen größeren technischen und praktischen Zusammenhang einzuordnen. Im Mittelpunkt steht dabei nicht die erneute Darstellung quantitativer Ergebnisse, sondern deren Interpretation im Hinblick auf die Forschungsfragen dieser Arbeit sowie die daraus resultierenden Implikationen für die KI-gestützte Softwareentwicklung. Darüber hinaus wird der Wandel der Entwicklerrolle diskutiert und kritisch reflektiert.

== Beantwortung der Forschungsfragen

In diesem Abschnitt werden die in Kapitel 1 formulierten Forschungsfragen auf Basis der empirischen Ergebnisse systematisch beantwortet.

=== RQ1: Wie beeinflusst KI die Entwicklungsgeschwindigkeit und Produktivität?

Die Ergebnisse zeigen, dass der Einsatz generativer KI eine erhebliche Beschleunigung bei der Erstellung von standardisiertem Code, insbesondere bei CRUD-Operationen und Boilerplate-Strukturen, ermöglicht. Die Implementierungszeit konnte im untersuchten Szenario deutlich reduziert werden.

Gleichzeitig verdeutlicht die Analyse, dass diese Zeitersparnis nicht automatisch zu einer proportionalen Steigerung der Netto-Produktivität führt. Insbesondere bei komplexeren Aufgaben verlagert sich der Aufwand in die Debugging- und Review-Phase. Die Ergebnisse deuten darauf hin, dass ein sogenannter Produktivitäts-Kipppunkt erreicht werden kann, sobald der zusätzliche Debugging-Aufwand die Einsparungen bei der Codegenerierung übersteigt.

Somit kann KI zwar die Entwicklungsgeschwindigkeit signifikant erhöhen, ihre produktive Wirkung ist jedoch stark kontextabhängig und erfordert eine sorgfältige Bewertung des Gesamtaufwands.

=== RQ2: Welche Auswirkungen hat KI auf Architektur, Integration und Systemstabilität?

Die Analyse macht deutlich, dass KI insbesondere bei globalen Architekturfragen und systemübergreifenden Aspekten Schwächen aufweist. Während lokal begrenzte Aufgaben zuverlässig umgesetzt werden, treten bei der Integration häufig Probleme auf, etwa in den Bereichen Persistenz, Sicherheitsmechanismen oder API-Verträgen.

Diese Beobachtungen lassen darauf schließen, dass KI primär lokal optimiert, jedoch kein konsistentes Gesamtverständnis der Systemarchitektur besitzt. Verstöße gegen Schichtentrennung oder unvollständige Sicherheitskonzepte sind typische Folgen. Für die Praxis bedeutet dies, dass KI-generierter Code ohne menschliche Kontrolle ein erhöhtes Risiko für strukturelle und sicherheitsrelevante Fehler birgt.

=== RQ3: Welche Strategien eignen sich zur Reduktion von KI-bedingten Fehlern?

Die Ergebnisse unterstreichen die Bedeutung gezielter Steuerungsmechanismen bei der Nutzung von KI. Insbesondere Prompt Engineering spielt eine zentrale Rolle, da die Qualität der KI-Ausgaben stark von der Präzision der Eingaben abhängt.

Gleichzeitig zeigt sich, dass Prompting allein nicht ausreicht, um systemische Fehler zuverlässig zu vermeiden. Notwendig sind ergänzende Maßnahmen wie iterative Codegenerierung, konsequente Reviews sowie klare architektonische Vorgaben durch den Menschen. KI kann somit effektiv unterstützt werden, ersetzt jedoch keine fundierten Software-Engineering-Prinzipien.

== Rollenwandel in der Softwareentwicklung durch KI

Die empirischen Ergebnisse dieser Arbeit weisen auf einen grundlegenden Wandel der Entwicklerrolle im Kontext KI-gestützter Softwareentwicklung hin.

=== Vom Code-Schreiber zum technischen Orchestrator

Traditionell lag der Schwerpunkt der Softwareentwicklung auf dem manuellen Schreiben von Code. Die Ergebnisse dieser Arbeit legen jedoch nahe, dass sich dieser Fokus zunehmend verschiebt.

Mit dem Einsatz generativer KI verlagern sich die Kernaufgaben der Entwicklerinnen und Entwickler hin zu übergeordneten Tätigkeiten wie Architekturplanung, Qualitätsbewertung, Debugging und Systemintegration. Der Mensch agiert zunehmend als steuernde Instanz, die KI-generierte Artefakte bewertet, anpasst und in den Gesamtkontext einordnet.

Diese Rolle kann als technischer Orchestrator verstanden werden, der nicht primär Code produziert, sondern den Entwicklungsprozess koordiniert und verantwortet.

=== Mensch–KI als hierarchisches Teammodell

Die Analyseergebnisse sprechen gegen ein symmetrisches Teammodell, in dem Mensch und KI als gleichwertige Akteure agieren. Stattdessen zeigt sich ein hierarchisches Human-in-the-Loop-Modell als praktikabler Ansatz.

In diesem Modell übernimmt die KI die Rolle einer ausführenden Instanz, die Vorschläge generiert und repetitive Aufgaben übernimmt. Die Verantwortung für architektonische Entscheidungen, Sicherheitsfragen und die Gesamtqualität verbleibt jedoch eindeutig beim Menschen.

Dieses Modell reduziert das Risiko kritischer Fehler und ermöglicht gleichzeitig eine produktive Nutzung der Stärken generativer KI.

== Prompt Engineering als Steuerungs- und Führungsinstrument

Prompt Engineering wird in dieser Arbeit nicht als rein technische Fertigkeit verstanden, sondern als methodisches Instrument zur Steuerung KI-gestützter Entwicklungsprozesse.

Prompts fungieren als implizite Spezifikation von Anforderungen, Constraints und Systemgrenzen. Sie bestimmen, welche Aufgaben die KI übernimmt und in welchem Rahmen sie agieren darf. Eine klare Definition von Nicht-Funktionalen Anforderungen, wie Sicherheits- oder Transaktionsregeln, ist dabei entscheidend für die Qualität der Ergebnisse.

Die Analyse deutet zudem darauf hin, dass eine iterative Vorgehensweise – bei der Code schrittweise generiert, überprüft und angepasst wird – die Fehleranfälligkeit signifikant reduziert. Prompt Engineering übernimmt damit eine ähnliche Funktion wie klassische Anforderungsanalyse und technische Spezifikation im traditionellen Software Engineering.

=== Multi-Model Workflows als erweiterte Strategie

Eine vielversprechende Erweiterung des Prompt Engineering liegt in der Nutzung von Multi-Model Workflows. Dabei werden spezialisierte KI-Modelle für unterschiedliche Aufgaben eingesetzt.

Ein möglicher Ansatz besteht darin, ein "Reasoning Model" (z.B. für konzeptionelle Planung und Architekturentscheidungen) zu nutzen, um detaillierte Spezifikationen und strukturierte Prompts zu erstellen. Diese werden anschließend an ein "Coding Model" übergeben, das die konkrete Implementierung übernimmt.

Dieser Ansatz trennt konzeptionelle Planung von der technischen Umsetzung und kann dazu beitragen, die in Kapitel 5 identifizierten Schwächen im Bereich der Architekturkohärenz zu reduzieren. Gleichzeitig ermöglicht er eine bessere Kontrolle über den Generierungsprozess und verringert das Risiko von Halluzinationen.

== Einordnung in den technischen und praktischen Kontext

Die Ergebnisse dieser Arbeit lassen sich in aktuelle Entwicklungen der KI-gestützten Softwareentwicklung einordnen. Generative KI wird zunehmend als produktivitätssteigerndes Werkzeug eingesetzt, insbesondere für standardisierte und wiederkehrende Aufgaben.

Gleichzeitig bestätigt diese Arbeit, dass KI derzeit kein vollständiges Systemverständnis besitzt und daher nicht autonom für komplexe architektonische oder sicherheitskritische Entscheidungen geeignet ist. Die beobachtete Verschiebung hin zu Review-, Kontroll- und Integrationsaufgaben entspricht gängigen industriellen Praktiken, in denen KI als Assistenzsystem und nicht als Ersatz für menschliche Expertise eingesetzt wird.

Somit positioniert sich diese Arbeit klar innerhalb eines praxisorientierten Verständnisses von KI als unterstützendes Werkzeug im Entwicklungsprozess.

== Kritische Würdigung und Limitationen

Wie jede empirische Untersuchung unterliegt auch diese Arbeit gewissen Einschränkungen.

Die interne Validität ist durch den begrenzten Projektumfang und die Beteiligung eines kleinen Entwicklerkreises eingeschränkt. Subjektive Einschätzungen, etwa bei der Bewertung der Codequalität, können nicht vollständig ausgeschlossen werden.

Die externe Validität ist ebenfalls limitiert, da die Ergebnisse stark vom verwendeten Technologie-Stack, der Projektgröße sowie den eingesetzten KI-Modellen abhängen. Eine direkte Übertragbarkeit auf andere Domänen oder Entwicklungsumgebungen ist daher nur eingeschränkt möglich.

Darüber hinaus hängt die Qualität der KI-Ausgaben maßgeblich von der Erfahrung der Entwicklerinnen und Entwickler im Umgang mit Prompting, Review und Debugging ab.

== Praktische Implikationen

Aus den Ergebnissen dieser Arbeit lassen sich mehrere praktische Konsequenzen ableiten:

- *Für Entwicklerinnen und Entwickler:*
  Zukünftige Kernkompetenzen liegen weniger im reinen Coding, sondern verstärkt in Architekturverständnis, Code-Review, Debugging und Qualitätsbewertung. Prompt Engineering entwickelt sich zu einer essentiellen Fähigkeit.

- *Für Unternehmen:*
  KI-gestützte Entwicklung erfordert angepasste QA- und Review-Prozesse, um verdeckte Logik- und Sicherheitsfehler frühzeitig zu erkennen. Dies kann zusätzliche Investitionen in Schulung und Prozessanpassung bedeuten.

- *Für Ausbildung und Lehre:*
  Fundamentale Kenntnisse in Softwarearchitektur, Datenmodellierung und Sicherheitskonzepten bleiben essenziell, um KI-generierten Code kritisch beurteilen zu können. Die Lehre sollte sich stärker auf Systemverständnis und Validierungskompetenz konzentrieren.
