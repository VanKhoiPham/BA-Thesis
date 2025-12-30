= Fazit und Ausblick

== Zusammenfassung

Diese Arbeit untersuchte die Auswirkungen von Generativer KI auf den Softwareentwicklungsprozess durch die praktische Entwicklung einer Restaurant-Bestell-App. Zwei unterschiedliche Workflows wurden verglichen: ein traditioneller Ansatz mit punktueller KI-Unterstützung ("Human First") und ein KI-zentrierter Ansatz ("AI First").

Die Ergebnisse zeigen, dass KI ein mächtiger Beschleuniger für repetitive Aufgaben sein kann, jedoch signifikante Schwächen im Verständnis komplexer Systemarchitekturen aufweist. Während der "AI First"-Ansatz eine enorme Zeitersparnis bei der initialen Implementierung bot (-88%), führte er zu einer deutlich höheren Fehlerrate und einem unverhältnismäßig hohen Debugging-Aufwand, der die Produktivitätsgewinne teilweise wieder zunichtemachte.

== Fazit

Die zentrale Erkenntnis dieser Arbeit ist, dass KI-Tools wie ChatGPT und Cursor zwar den Entwicklungsprozess beschleunigen, aber (noch) nicht die Rolle des Softwarearchitekten übernehmen können.

Der **Hybrid Workflow** erwies sich als der überlegene Ansatz. Er kombiniert die Geschwindigkeit der KI bei der Code-Erzeugung mit der planenden Voraussicht und Qualitätskontrolle des Menschen. In diesem Modell wandelt sich der Entwickler vom "Handwerker", der Code schreibt, zum "Architekten und Prüfer", der KI-Ergebnisse bewertet, integriert und korrigiert.

KI ist somit kein Ersatz für menschliche Expertise, sondern ein Werkzeug, das diese Expertise auf eine höhere Abstraktionsebene hebt. Ohne fundiertes Verständnis von Architektur und Sicherheit seitens des Entwicklers bleibt der Einsatz von KI risikobehaftet.

== Ausblick

Die rasante Entwicklung im Bereich der KI lässt erwarten, dass einige der identifizierten Schwächen (z.B. Kontext-Limitierungen) in naher Zukunft gemildert werden. Zukünftige Forschungsfelder könnten sich auf folgende Aspekte konzentrieren:

- **Langzeit-Wartbarkeit:** Wie verhält sich KI-generierter Code über einen längeren Lebenszyklus von mehreren Jahren? Ist er wartbarer oder anfälliger für "Software Erosion"?
- **AI Agents:** Neue Entwicklungen hin zu autonomen Agenten (z.B. Devin), die ganze Aufgabenketten (Planen, Coden, Testen, Fixen) übernehmen können, könnten die Ergebnisse von RQ2 (Architekturverständnis) grundlegend verändern.
- **Integration in CI/CD:** Die Untersuchung von Workflows, bei denen KI direkt in die Integrationspipelines eingebunden ist, um automatisch fehlgeschlagene Tests zu analysieren und Fixes vorzuschlagen ("Self-Healing Systems").
