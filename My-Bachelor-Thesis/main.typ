// Register abbreviations and glossary
#import "dependencies.typ": make-glossary, print-glossary, register-glossary
#show: make-glossary
// Abbreviations
#import "abbreviations.typ": abbreviations-entry-list
#register-glossary(abbreviations-entry-list)
// Glossary
#import "glossary.typ": glossary-entry-list
#register-glossary(glossary-entry-list)

// Take a look at the file `template.typ` in the file panel
#import "../lib/lib.typ": bachelor-thesis, declaration-of-independent-processing
#show: bachelor-thesis.with(
  language: "de", // Assuming German based on PDF

  title-de: "Optimierter Softwareentwicklungsprozess durch KI: Eine Fallstudie anhand einer Restaurant Bestell-App",
  keywords-de: (
    "Generative KI",
    "Software-Engineering",
    "Large Language Models (LLM)",
    "Quarkus",
    "SvelteKit",
    "KI-gestützte-Entwicklung",
    "Code-Refactoring",
    "Fallstudie",
    "Prompt Engineering",
    "Fullstack-Entwicklung",
  ),
  abstract-de: [Der Einsatz von künstlicher Intelligenz (KI) in der Softwareentwicklung führt derzeit zu grundlegenden Veränderungen in der Branche. Diese rasante Entwicklung zeigt sich im Übergang von einfachen Chatbots (wie ChatGPT), die spezifische Fragen beantworten, hin zu integrierten KI-Agenten, die aktiv bei der Programmierung und dem Projektmanagement unterstützen. Ziel dieser Bachelorarbeit ist es, die Auswirkungen spezifischer KI-Werkzeuge – insbesondere ChatGPT (für die Architekturplanung) und Gemini (für die Implementierung) – auf den gesamten Entwicklungsprozess einer modernen Webanwendung zu untersuchen. Als Fallstudie dient eine QR-Code-basierte Restaurant-Bestellplattform, die im Backend mit Java Quarkus und im Frontend mit SvelteKit implementiert wurde. Anhand dieses Praxisbeispiels wird ein direkter Vergleich zwischen der manuellen und der KI-gestützten Entwicklung durchgeführt.
    Die Untersuchung analysiert kritische Phasen des Software-Lebenszyklus: von der Architekturkonzeption und Konfiguration über die Implementierung bis hin zum Debugging. Die Ergebnisse zeigen, dass der Einsatz von KI die "akzidentelle Komplexität" (Accidental Complexity) während der Initialisierungsphase und beim Schreiben von Boilerplate-Code signifikant reduziert. Dies ermöglicht eine Beschleunigung der Entwicklung von Standardfunktionen (CRUD) um bis zu 80%. Dennoch deckt die Studie signifikante Risiken auf: KI-Modelle neigen zu "Kontext-Halluzinationen" bei der Integration verteilter Systemkomponenten und vernachlässigen häufig tiefergehende Framework-Restriktionen (z. B. Transaktionsgrenzen in Hibernate), was zu subtilen Laufzeitfehlern führt.],

  title-en: "Optimierter Softwareentwicklungsprozess durch KI: Eine Fallstudie anhand einer Restaurant
Bestell-App",
  keywords-en: ("Keyword", "Important", "Super"),
  abstract-en: "Abstract...",

  author: "Van Khoi Pham",
  faculty: "Computer Science and Digital Society",
  study-course: "Bachelor of Science Informatik Technischer Systeme", // Default, user can change
  supervisors: ("Prof. Dr. Stefan Sarstedt", "Prof. Dr. Olaf Zukunft"),
  submission-date: datetime.today(),

  // Everything inside "before-content" will be automatically injected
  // into the document before the actual content starts.
  before-content: {
    // Print abbreviations
    pagebreak(weak: true)
    heading("Abkürzungsverzeichnis", numbering: none)
    print-glossary(
      abbreviations-entry-list,
      disable-back-references: true,
    )
  },
  // Everything inside "after-content" will be automatically injected
  // into the document after the actual content ends.
  after-content: {
    // Print glossary
    pagebreak(weak: true)
    heading("Glossar", numbering: none)
    print-glossary(
      glossary-entry-list,
      disable-back-references: true,
    )

    // Print bibliography
    pagebreak(weak: true)
    bibliography("bibliography.bib", style: "../lib/assets/ieeetran.csl", title: "Literaturverzeichnis")

    // Declaration of independent processing (comment out to remove)
    include "declaration.typ"
  },
)

// Include chapters of thesis
// Include chapters of thesis
#pagebreak(weak: true)
// #include "chapters/01_preamble.typ"
// #include "chapters/02_articles.typ"
// #include "chapters/05_analysis.typ"
// #include "chapters/06_ki_tools.typ"

#include "chapters/01_einleitung.typ"
#pagebreak(weak: true)
#include "chapters/02_grundlagen.typ"
#pagebreak(weak: true)
#include "chapters/03_umsetzung.typ"
#pagebreak(weak: true)
#include "chapters/04_vergleich.typ"
#pagebreak(weak: true)
#include "chapters/05_analyse.typ"
#pagebreak(weak: true)
#include "chapters/06_diskussion.typ"
#pagebreak(weak: true)
#include "chapters/07_fazit.typ"
