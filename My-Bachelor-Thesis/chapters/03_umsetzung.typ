= Umsetzung der Beispielanwendung

== Anforderungsanalyse
=== Einleitung und Vision
Das Ziel dieses Projektes ist die Entwicklung eines digitalen Bestellsystems ("QR Restaurant App"), das den traditionellen Gastronomieprozess modernisiert. Das System ermöglicht es Gästen, über ihr eigenes Smartphone direkt am Tisch zu bestellen. Dies soll Wartezeiten verkürzen, das Servicepersonal entlasten und die Effizienz in der Küche durch digitale Echtzeit-Übermittlung steigern.

=== Benutzergruppen und Akteure
#figure(
  image("../images/ContextDiagram.svg", width: 100%),
  caption: [Kontextdiagramm des Systems (Quelle: Generiert mit ChatGPT, visualisiert mit PlantText)],
  kind: image,
)
Für das System wurden drei Hauptakteure identifiziert:
- *Der Gast*: Besucht das Restaurant, scannt einen QR-Code und bestellt selbstständig, ohne auf Servicepersonal warten zu müssen.
- *Das Küchenpersonal*: Benötigt eine übersichtliche Darstellung eingehender Bestellungen in Echtzeit, um diese effizient zuzubereiten.
- *Der Restaurantmanager*: Ist verantwortlich für die Verwaltung des Systems, einschließlich Speisekarte, Personal und Umsatzanalyse.



=== Funktionale Anforderungen (Soll-Zustand)

==== Das Gasterlebnis (Customer Journey)
- *[FA-01] Barrierefreier Zugang*: Der Zugriff erfolgt über einen QR-Code am Tisch. Eine App-Installation oder Registrierung darf nicht erforderlich sein.
- *[FA-02] Kollaboratives Bestellen*: Das System muss unterstützen, dass mehrere Gäste an einem Tisch gleichzeitig individuelle Bestellungen aufgeben können (Guest Sessions), die logisch dem Tisch zugeordnet bleiben.
- *[FA-03] Digitale Speisekarte*: Die Speisekarte soll kategorisiert dargestellt werden, inklusive Filterfunktionen und detaillierten Produktbeschreibungen.
- *[FA-04] Warenkorb & Bestellabgabe*: Gäste können Artikel auswählen, im Warenkorb sammeln und verbindlich an die Küche senden.
- *[FA-05] Flexibler Bezahlvorgang*: Das System muss verschiedene Bezahlmethoden (Bar, Karte) unterstützen und flexible Abrechnungsmodelle ermöglichen (Gesamtrechnung für den Tisch oder getrennte Rechnungen pro Gast).

==== Küchenprozesse
- *[FA-06] Echtzeit-Synchronisation*: Neue Bestellungen müssen ohne manuelles Neuladen der Seite (via Server-Sent Events) sofort auf dem Küchendisplay erscheinen.
- *[FA-07] Statusverfolgung*: Der Status einer Bestellung (z. B. "Neu", "In Zubereitung", "Fertig") muss durch das Personal aktualisierbar sein, um den Fortschritt transparent zu machen.

==== Management & Administration
- *[FA-08] Dynamische Speisekartenverwaltung*: Der Manager muss Gerichte erstellen, bearbeiten und deren Verfügbarkeit (aktiv/inaktiv) in Echtzeit steuern können.
- *[FA-09] Personalverwaltung*: Das System muss eine rollenbasierte Zugriffsverwaltung bieten, um Accounts für Manager, Kellner und Küchenpersonal sicher zu verwalten.
- *[FA-10] Umsatzanalyse & Berichte*: Es soll ein Dashboard bereitgestellt werden, das Umsatzdaten, Bestellvolumen und Topseller-Artikel visualisiert.
- *[FA-11] Flexibles Aktionsmanagement (Promotions)*: Das System muss dem Manager ermöglichen, Rabattaktionen zu erstellen und deren Gültigkeitsbereich flexibel zu konfigurieren. Es muss möglich sein, Aktionen entweder global auf das gesamte Menü (z. B. 10% Rabatt auf die Gesamtrechnung) oder gezielt für spezifische Tische (z. B. Rabatt nur für Tisch "T1" oder VIP-Bereiche) anzuwenden. Diese Aktionen sollen in Echtzeit aktiviert oder deaktiviert werden können.
- *[FA-12] Zentralisierte Zahlungsabwicklung (Manager-gesteuert)*: Die Finalisierung des Bezahlvorgangs obliegt ausschließlich dem Manager. Das System muss sicherstellen, dass nur autorisiertes Personal (Manager) die Zahlungsmethode (z. B. Bar, Karte, PayPal) auswählen und die Transaktion als „bezahlt“ markieren kann. Dies verhindert Fehlbuchungen und stellt sicher, dass der physische Geldfluss (Cash/POS) mit dem Systemstatus übereinstimmt.

=== Nicht-funktionale Anforderungen

==== Benutzbarkeit (Usability)
- Das Frontend für den Gast muss nach dem "Mobile First"-Ansatz gestaltet sein und eine intuitive Bedienung ohne Einweisung ermöglichen.

==== Leistung & Skalierbarkeit
- Das System muss auch bei hoher Auslastung (viele gleichzeitige Verbindungen) reaktionsschnell bleiben. Die Latenz zwischen Bestellung und Anzeige in der Küche sollte minimiert werden.

==== Sicherheit
- Kritische Bereiche (Management, Küche) müssen durch eine sichere Authentifizierung geschützt sein.
- Datenschutz: Gäste dürfen keinen Zugriff auf Bestellungen anderer Tische haben.

== Systemarchitektur & Technologie

=== *Technologie-Stack*:
- *Backend*: Java Quarkus (für hohe Performance und schnelle Startzeiten).
- *Frontend*: SvelteKit (für ein reaktives Benutzererlebnis).
- *Datenbank*: PostgreSQL (für relationale Datenintegrität).

=== *Grobarchitektur*:
- Die Gesamtarchitektur folgt dem klassischen Client-Server-Modell, wobei eine strikte Trennung von Verantwortlichkeiten (Separation of Concerns) angestrebt wird.
#figure(
  image("../images/ComponentDiagram.svg", width: 100%),
  caption: [Componentdiagramm des Systems (Quelle: Generiert mit ChatGPT, visualisiert mit PlantText)],
  kind: image,
)
- *Der Client (Frontend)*: Agiert als "Thin Client". Er ist verantwortlich für die Darstellung der Daten (UI) und die Interaktion mit dem Benutzer. Er hält keine Geschäftslogik, die über die Validierung von Eingaben hinausgeht.
- *Der Server (Backend)*: Hält die gesamte Geschäftslogik, verwaltet den Zustand der Anwendung und sichert die Datenintegrität. Er stellt eine RESTful API zur Verfügung, über die der Client Daten abruft oder Änderungen sendet.
- *Echtzeit-Kommunikation*: Für zeitkritische Anwendungsfälle, wie die Benachrichtigung der Küche bei neuen Bestellungen, ist ergänzend zu REST der Einsatz von Server-Sent Events (SSE) geplant. Dies ermöglicht dem Server, Daten aktiv an den Client zu pushen (Unidirektional), ohne dass der Client ständig nachfragen muss (Polling).



=== *Backend Architektur*
// Sơ đồ 4 tầng: Resource -> Service -> Repository -> Model.
#figure(
  image("../images/LayerDiagram.svg", width: 100%),
  caption: [Schichtendiagramm des Systems (Quelle: Generiert mit ChatGPT, visualisiert mit PlantText)],
  kind: image,
)
Die Anwendung folgt einer 4-Schichten-Architektur:
- *Resource*: REST-Endpunkte.
- *Service*: Geschäftslogik.
- *Repository*: Datenzugriff.
- *Model*: Datenstrukturen.

== Datenmodell
#figure(
  image("../images/ER Diagram.svg", width: 100%),
  caption: [Schichtendiagramm des Systems (Quelle: Generiert mit ChatGPT, visualisiert mit PlantText)],
  kind: image,
)
// ER Diagram: Các bảng chính (tables, orders, bills, staff, promotions).
Das Datenmodell umfasst folgende Haupttabellen (siehe ER-Diagramm):
- `tables` (Tische)
- `guest_sessions` (Gastsitzungen)
- `staff` (Personal)
- `menu_items` (Speisekarte/Menüpunkte)
- `order_items` (Bestellpositionen)
- `bills` (Rechnungen)
- `payments` (Zahlungen)
- `promotions` (Sonderangebote)

== Kernprozesse & Sequenzdiagramme
=== Prozessbeschreibung (Workflow - Konzept)
+ *QR-Code Scannen & Identifikation:*
  - Der Gast scannt einen tischspezifischen QR-Code.
  - Das System identifiziert den Tisch und prüft dessen Verfügbarkeit.
  - Der Gast meldet sich an (z.B. mit einem Spitznamen), um eine Sitzung zu starten.
+ *Bestellung aufgeben (Ordering):*
  - Das System lädt die digitale Speisekarte.
  - Der Gast wählt Artikel aus und sendet die Bestellung ab.
  - Das System validiert die Bestellung und speichert sie zentral.
  - Die Küche wird *in Echtzeit* über den neuen Auftrag informiert.
+ *Küche & Zubereitung:*
  - Das Küchenpersonal sieht die offenen Bestellungen auf einer Anzeige (Kitchen Display).
  - Der Status wird je nach Fortschritt aktualisiert (z.B. "In Zubereitung" -> "Fertig").
+ *Rechnung & Zahlung (durch Manager):*
  - Der Gast signalisiert den Bezahlwunsch.
  - Der Manager ruft die Rechnung für den entsprechenden Tisch im System ab.
  - Das System fasst alle Bestellungen des Tisches zusammen.
  - Der Manager kassiert den Betrag (Bar/Karte) und verbucht den Zahlungseingang im System.
  - Der Tisch wird im System wieder als "Frei" markiert.

=== Sequenzdiagramme

#figure(
  image("../images/SequenzDiagramm.svg", width: 59%),
  caption: [Sequenzdiagramm des Systems (Quelle: Generiert mit ChatGPT, visualisiert mit PlantText)],
  kind: image,
)

=== Cơ chế thời gian thực (Echtzeit-Mechanismus / Server-Sent Events)
