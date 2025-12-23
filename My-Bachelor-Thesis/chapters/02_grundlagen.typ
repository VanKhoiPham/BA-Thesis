= Grundlagen

== Technologie-Stack
// Backend: Quarkus (Java 21), Hibernate ORM (Active Record vs Repository), PostgreSQL.
Für das Backend wird *Quarkus* (Java 21) in Kombination mit *Hibernate ORM* verwendet, wobei die Unterschiede zwischen dem Active Record Pattern und dem Repository Pattern betrachtet werden. Als Datenbank kommt *PostgreSQL* zum Einsatz.

// Frontend: SvelteKit 2, TailwindCSS.
Das Frontend wird mit *SvelteKit 2* und *TailwindCSS* realisiert.

== KI-gestützte Entwicklung
// Khái niệm LLM, Context Window.
Dieser Abschnitt erläutert die Grundlagen von Large Language Models (LLMs) und das Konzept des "Context Window".

// Công cụ: ChatGPT (Architect role), Cursor (Coding role).
Es werden die verwendeten Tools vorgestellt:
- *ChatGPT*: Eingesetzt in der Rolle des Software-Architekten für Planung und Design.
- *Cursor*: Eingesetzt als direkter Coding-Assistent in der IDE.

#figure(
  rect(width: 100%, height: 50pt, fill: gray.lighten(50%))[
    #align(center + horizon)[Platzhalter für Architektur-Diagramm]
  ],
  caption: [Übersicht der KI-Tools],
  kind: image,
)

== Metriken
// Tốc độ (Development Velocity).
- *Entwicklungsgeschwindigkeit (Development Velocity)*: Zeitaufwand für die Implementierung von Features.
// Chất lượng mã (Code Quality - Coupling/Cohesion).
- *Code-Qualität*: Bewertung anhand von Kopplung (Coupling) und Kohäsion (Cohesion).
// Độ ổn định (Stability/Bug rate).
- *Stabilität*: Analyse der Fehlerrate (Bug Rate) und Robustheit des Systems.
