= Vergleichen in bestimmten Phasen

Dieses Kapitel präsentiert die praktischen Ergebnisse aus der Entwicklung des Restaurant Bestell-App. Anstatt eines statischen Vergleichs zwischen "mit KI" und "ohne KI" wurde der Entwicklungsprozess in zwei verschiedene Arbeitsabläufe (Workflows) unterteilt. Dieser Ansatz ermöglicht eine vertiefte Analyse der Fähigkeiten von KI, insbesondere hinsichtlich der Unterstützung von Entwickler*innen während des Softwareentwicklungsprozesses. Darüber hinaus werden Informationen zur Codequalität, zur Entwicklungsgeschwindigkeit sowie zu den auftretenden Fehlern, Bugs im KI-gestützten Programmieren systematisch erfasst und zusammengeführt.

Die Analyse stützt sich auf konkrete Commit-Logs, Fehlerprotokolle und Code-Metriken, die während der Projektlaufzeit erhoben wurden.

== Einführung in die Arbeitsabläufe

// Erstens wurden die Funktionen für die Nutzergruppen Guest und Küchenpersonal nach dem Prinzip „Mensch zuerst – KI danach“ entwickelt: Die Implementierung erfolgte zunächst durch die Entwickler*innen, anschließend wurde KI eingesetzt, um den Code zu optimieren, Refactorings vorzuschlagen und die Codequalität zu verbessern.

// Zweitens wurden die Funktionen für den Manager nach dem umgekehrten Prinzip „KI zuerst – Mensch danach“ umgesetzt: Hier generierte die KI zunächst den Entwurf bzw. den initialen Quellcode, woraufhin die Entwickler*innen die Ergebnisse systematisch prüften, bewerteten und bei Bedarf korrigierten, um Korrektheit, Qualität sowie die Erfüllung der Anforderungen sicherzustellen.

Um die Effektivität der KI-Unterstützung in in unterschiedlichen Entwicklungskontexten zu evaluieren, wurde das Projekt in zwei klar voneinander abgegrenzte Phasen unterteilt, die jeweils einem eigenen Arbeitsablauf (Workflow) entsprechen.

- Erstens wurden die Funktionen für die Nutzergruppen Guest und Küchenpersonal nach dem Prinzip „Mensch zuerst – KI danach“ entwickelt

- Zweitens wurden die Funktionen für den Manager nach dem umgekehrten Prinzip „KI zuerst – Mensch danach“ umgesetzt

Diese Unterscheidung ist notwendig, da die Auswirkungen der KI stark davon abhängen, ob sie korrigierend (Refactoring) oder generierend (Prototyping) eingesetzt wird.

== Workflow 1: „Mensch zuerst – KI danach“ (Human → AI Optimization)

In diesem Workflow implementiert der Entwickler zunächst eine erste lauffähige Version der jeweiligen Funktionalitäten. Anschließend wird KI eingesetzt, um konkrete Verbesserungsvorschläge zu liefern, Refactorings anzuregen und den Quellcode hinsichtlich Struktur, Lesbarkeit und Performance zu optimieren. Ziel ist es, die Codequalität sowie die Wartbarkeit systematisch zu erhöhen.

=== Konfiguration: Technische Hürden & "Accidental Complexity"
#heading("A. Manuelle Herausforderungen:", level: 4, numbering: none)
Bei der manuellen Durchführung verließ sich der Entwickler auf fragmentierte Tutorials aus dem Internet, was zu einer Vermischung inkompatibler Konfigurationen und der Verwendung veralteter Syntax führte. Dies führte zu zwei schwerwiegenden Problemen, die den Projektstart lahmlegten:

+ *Bibliothekskonflikte ("Dependency Hell")*:
  Beim Versuch, die notwendigen Bibliotheken für Quarkus zu integrieren, fügte der Entwickler unabsichtlich zwei verschiedene REST-Stacks in die `pom.xml` ein: `quarkus-rest` (Reactive, neu) und `quarkus-resteasy` (Classic, alt).

  #figure(
    caption: [Bibliothekskonflikte in der `pom.xml`],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```bash
      <!-- Reactive ( Not necessary) -->
      <dependency>
          <groupId>io.quarkus</groupId>
          <artifactId>quarkus-rest</artifactId>
      </dependency>


      <!-- quarkus-resteasy (Legacy/Conflict) -->
      <dependency>
          <groupId>io.quarkus</groupId>
          <artifactId>quarkus-resteasy</artifactId>
      </dependency>
      <dependency>
          <groupId>io.quarkus</groupId>
          <artifactId>quarkus-resteasy-jackson</artifactId>
      </dependency>
      <!-- CORRECT  -->
      <dependency>
          <groupId>io.quarkus</groupId>
          <artifactId>quarkus-rest-jackson</artifactId>
      </dependency>

      <!--  Single Integrated Stack, AI đề xuất nhưng sai -->
      <dependency>
          <groupId>io.quarkus</groupId>
          <artifactId>quarkus-resteasy-reactive-jackson</artifactId>
      </dependency>
      ```
    ],
  )
  - *Folge*: Der Build-Prozess schlug mit einer `java.lang.IllegalStateException` vollständig fehl.
  #block(fill: luma(240), inset: 8pt, radius: 4pt)[
    ```bash
    ...
    Caused by: java.lang.IllegalStateException: Please make sure there is only one provider of the following capabilities: capability io.quarkus.rest is provided by: - io.quarkus:quarkus-rest:3.29.2 - io.quarkus:quarkus-resteasy:3.29.2 capability io.quarkus.rest.jackson is provided by: - io.quarkus:quarkus-rest-jackson:3.29.2 - io.quarkus:quarkus-resteasy-jackson:3.29.2
    ```
  ]
  - *Fehlerprotokoll*: Das System gab einen Stack-Trace von über 200 Zeilen zurück.
  - *Auswirkung*: Der Entwickler verbrachte etwa 45 Minuten mit dem Lesen von Logs, dem Studium der Quarkus-Dokumentation zu "Capabilities" und dem manuellen Entfernen von Abhängigkeiten.

+ *Veraltete Konfiguration (Legacy Configuration - CORS)*:
  Nach der Lösung der Abhängigkeiten trat das nächste Problem auf, als das Frontend versuchte, die API aufzurufen. Der Browser blockierte die Anfragen aufgrund von CORS-Fehlern (Cross-Origin Resource Sharing).

#figure(
  caption: [Fehlerhafte CORS Konfiguration],
  supplement: [Listing],
  kind: raw,
  block(fill: luma(240), inset: 8pt, radius: 4pt)[
    ```bash
    quarkus.http.cors=true ❌
    <!-- nicht gultig in diese Version  -->
    quarkus.http.cors.origins=http://localhost:5173
    quarkus.http.cors.methods=GET,POST,PUT,DELETE,OPTIONS ❌
    <!-- fehlt noch PATCH  -->
    quarkus.http.cors.headers=accept,authorization,content-type,x-requested-with
    ```
  ],
)

- *Ursache*: Der Entwickler verwendete die veraltete Konfiguration `quarkus.http.cors=true` in `application.properties`, die in älteren Artikeln zu finden war. In der verwendeten Quarkus-Version 3.x wurde dieser Schlüssel jedoch geändert.
// - *Fehlermeldung*:
- *Zusätzliches Problem*: Der Entwickler vergaß zudem, die PATCH-Methode (für Statusaktualisierungen) zuzulassen, was dazu führte, dass OPTIONS-Anfragen (Preflight) abgelehnt wurden.

#heading("B. Die KI-Lösung:", level: 4, numbering: none)

Im Gegensatz zum Trial-and-Error-Prozess des Menschen agierte die KI als aktueller Framework-Experte.

+ *Automatische Standardisierung von Abhängigkeiten*:
  Auf die Anfrage "Erstelle ein Quarkus-Projekt mit Hibernate und REST" generierte die KI von Anfang an eine korrekte `pom.xml`.
  - *Lösung*: Die KI verwendete ausschließlich den modernen Stack `quarkus-rest-jackson` und eliminierte konfliktäre Bibliotheken wie `quarkus-resteasy`.
  - *Ergebnis*: Das Projekt wurde sofort erfolgreich und ohne "Duplicate capability"-Fehler gebaut.

+ *Sofortige korrekte Konfiguration*:
  Beim CORS-Problem erkannte die KI anhand des Fehlerlogs sofort den Versionsunterschied zwischen Quarkus 2.x und 3.x.
  - *Lösung*: Die KI schlug eine `application.properties` mit der korrekten Syntax vor.
  - *Auswirkung*: Die Zeit für die Dokumentationsrecherche und das Debuggen der Verbindung zwischen Frontend und Backend entfiel vollständig.

#heading("C. Fazit der Konfigurationsphase:", level: 4, numbering: none)
Das Eingreifen der KI in dieser Phase eliminierte die "Einrichtungsreibung" (Setup Friction).
- *Zeit*: Reduzierung von ungefähr 60 Minuten (manuelles konfigurieren und Debuggen) auf 5 Minuten (KI-Generierung & Review).
- *Psychologie*: Bewahrte den Entwickler vor Frustration gleich zu Beginn des Projekts und ermöglichte den Fokus auf die Geschäftslogik anstatt auf den Kampf mit Konfigurationsdateien.

=== Backend: Struktur, Datenzugriffsmuster, Geschäftslogik und Abhängigkeiten
Dieser Abschnitt dokumentiert die technische Umsetzung und die Unterschiede zwischen *der ursprünglichen Version* (`Version 1`) und *der KI Version* (`Version 2`) des Backend-Systems. Die Änderungen betreffen die Paketstruktur, das Datenzugriffsmuster, das Abhängigkeitsmanagement sowie die Organisation gemeinsamer Domänenobjekte.

#heading("A. Projektstruktur (Project Structure):", level: 4, numbering: none)

+ *Version 1: Schichtenarchitektur (Layered Architecture):*

  In der ersten Iteration wurde der Quellcode horizontal nach technischen Schichten organisiert. Dies führte dazu, dass Klassen, die zu einer fachlichen Funktion gehörten, über verschiedene Pakete verteilt waren.

  #figure(
    caption: [Dateistruktur in Version 1 (Schichtenarchitektur)],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```bash
        src/main/java/com/example
      ├── entity                  // Alle Datenbankmodelle
      │   ├── GuestSession.java
      │   ├── OrderItem.java
      │   └── TableEntity.java
      ├── service                 // Die gesamte Geschäftslogik
      │   ├── GuestSessionService.java
      │   ├── OrderService.java
      │   └── TableService.java
      └── resource                // Alle REST-Endpunkte
          ├── GuestSessionResource.java
          └── OrderResource.java
          └── TableResource.java
      ```
    ],
  )

  *Problem (geringe Kohäsion)*: Um eine einzelne Funktionalität (z. B. „Bestellung aufgeben“) zu ändern, muss der Entwickler zwischen drei getrennten Verzeichnissen hin- und herwechseln. Mit zunehmender Projektgröße entwickelt sich das Service-Package zu einem „God Package“, das dutzende Dateien enthält, die inhaltlich kaum miteinander zusammenhängen.

+ *Version 2: Schichtenarchitektur (Layered Architecture):*

  In der zweiten Iteration wurde die Struktur vertikal nach fachlichen Domänen (Features) reorganisiert. Jedes Paket repräsentiert nun ein eigenständiges Modul, das alle notwendigen Schichten beinhaltet.

  #figure(
    caption: [Dateistruktur in Version 2 (Fachliche Module)],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```bash
      src/main/java/com/example
      ├── guestsession            // Modul für Gästesitzungen
      │   ├── model/GuestSession.java
      │   ├── repository/GuestSessionRepository.java
      │   ├── service/GuestSessionService.java
      │   └── rest/GuestSessionResource.java
      ├── order                   // Modul für Bestellungen
      │   ├── model/OrderItem.java
      │   ├── repository/OrderItemRepository.java
      │   ├── service/OrderService.java
      │   └── rest/OrderResource.java
      └── common                  // Gemeinsam genutzte Ressourcen
          └── domain (Enums: OrderStatus, PaymentMethod)
      ```
    ],
  )

  *Vorteil (hohe Kohäsion)*: Sämtliche Logik, die zu einer bestimmten Funktionalität gehört, ist an einem zentralen Ort gebündelt. Dadurch wird die Navigation im Projekt deutlich erleichtert und zugleich eine solide Grundlage geschaffen, um die Anwendung bei Bedarf später in Microservices zu zerlegen.


#heading("B. Datenzugriffsmuster (Data Access Pattern):", level: 4, numbering: none)

+ *Version 1: Active Record Pattern:*

  Die Entitätsklassen erbten direkt von `PanacheEntity` und waren sowohl für die Datenhaltung als auch für die Datenbankoperationen verantwortlich. Der Zugriff erfolgte über statische Methoden.

  #figure(
    caption: [Entität in Version 1],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```java
      // com.example.entity.GuestSession.java
      @Entity
      public class GuestSession extends PanacheEntity {
          public String nickname;
          public boolean active;

          // Keine separate Repository-Klasse.
          // Nutzung im Code: GuestSession.findById(id);
      ```
    ],
  )

  *Nachteil:* Es entsteht eine enge Kopplung (tight coupling) zwischen der Geschäftslogik und der Datenbank. Dadurch wird das Schreiben von Unit-Tests erheblich erschwert, da sich statische Methoden (z. B. `GuestSession.persist`) nicht bzw. nur mit hohem Aufwand mocken lassen.

+ *Version 2: Repository Pattern:*

  Die Entitäten wurden zu reinen Datenobjekten (*POJOs*) reduziert. Die Datenbanklogik wurde in dedizierte Repository-Klassen ausgelagert, die das Interface `PanacheRepository` implementieren.

  #figure(
    caption: [Entität und Repository in Version 2],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```java
      // com.example.guestsession.model.GuestSession.java
      @Entity
      @Table(name = "guest_sessions")
      public class GuestSession extends PanacheEntity {
          public String nickname;
          // Enthält keine Logik mehr
      }

      // com.example.guestsession.repository.GuestSessionRepository.java
      @ApplicationScoped
      public class GuestSessionRepository implements PanacheRepository<GuestSession> {
          // Kapselt spezifische Datenbankabfragen
          public List<GuestSession> listActiveByTable(Table table) {
              return list("table = ?1 and active = true", table);
          }
      }
      ```
    ],
  )

  *Vorteil:* Die Testbarkeit (Testability) wird deutlich erhöht. In der Testumgebung kann das `GuestSessionRepository` problemlos durch ein Mock-Objekt ersetzt werden, sodass Tests schnell ausgeführt werden können und unabhängig von der Datenbank bleiben.

#heading("C. Geschäftslogik und Abhängigkeiten (Business Logic & Dependencies):", level: 4, numbering: none)
+ *Version 1: Implizite Abhängigkeiten:*

  Die Services griffen direkt auf die statischen Methoden der Entitäten zu (`Hard Dependencies`). Es war nicht ersichtlich, welche externen Ressourcen eine Klasse benötigte.

  #figure(
    caption: [Service-Implementierung in Version 1],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```java
      // com.example.service.OrderService.java
      public class OrderService {
          public void placeOrder(Long sessionId, Long menuId) {
              // Direkter, statischer Zugriff auf die Datenbank
              GuestSession session = GuestSession.findById(sessionId);
              MenuItem item = MenuItem.findById(menuId);

              if (session == null) throw new NotFoundException();

              OrderItem order = new OrderItem();
              order.session = session;
              order.item = item;
              order.persist(); // Speichern direkt über die Entität
          }
      }
      ```
    ],
  )

  *Nachteil:* Änderungen an der Persistenzschicht (z. B. Datenbankschema oder ORM-Details) wirken sich schnell auf die Business-Logik aus, was Wartung und Weiterentwicklung unnötig kompliziert macht.

+ *Version 2: Dependency Injection (CDI):*

  Die Services nutzen nun *Dependency Injection*, um Instanzen der Repositories zu erhalten. Abhängigkeiten werden explizit deklariert, was die Modularität erhöht.

  #figure(
    caption: [ Service-Implementierung in Version 2],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```java
      // com.example.order.service.OrderService.java
        @ApplicationScoped
        public class OrderService {

            // Explizite Deklaration der Abhängigkeiten
            @Inject GuestSessionRepository guestSessionRepository;
            @Inject MenuItemRepository menuItemRepository;
            @Inject OrderItemRepository orderItemRepository;

            public void placeOrder(Long sessionId, Long menuId) {
                // Zugriff über die injizierten Repositories
                GuestSession session = guestSessionRepository.findById(sessionId);
                MenuItem item = menuItemRepository.findById(menuId);

                if (session == null) throw new NotFoundException();

                OrderItem order = new OrderItem();
                order.guestSession = session;
                order.menuItem = item;
                orderItemRepository.persist(order); // Speichern über das Repository
            }
        }
      ```
    ],
  )

  *Vorteil:* Durch die klare Trennung von Verantwortlichkeiten (Separation of Concerns) bleibt die Business-Logik unabhängiger von der Datenzugriffsschicht, wodurch Refactorings und spätere Anpassungen leichter umsetzbar sind.

#heading("D. Gemeinsame Domänenlogik (Shared Domain Logic):", level: 4, numbering: none)

+ *Version 1: Verteilte Definitionen:*

  In der ursprünglichen Version waren Aufzählungstypen (`Enums`) oft direkt in den Paketen definiert, in denen sie zuerst verwendet wurden. Dies führte zu problematischen Abhängigkeiten, wenn andere Module diese Typen ebenfalls benötigten.

  #figure(
    caption: [ Problem der zirkulären Abhängigkeit in Version 1 in Version 2],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```java
      // com.example.entity.Order.java
      package com.example.entity;
      // OrderStatus ist hier definiert, wird aber auch von Payment benötigt
      public enum OrderStatus { NEW, PAID, CANCELED }

      // com.example.service.BillingService.java
      package com.example.service;
      import com.example.entity.OrderStatus; // Billing hängt von Order ab
      // Wenn Order auch Billing benötigt, entsteht ein Zyklus
      ```
    ],
  )

  // *Nachteil:*

+ *Version 2: Zentralisiertes Common-Modul:*

  Ein dediziertes `common`-Modul wurde eingeführt (`com.example.common`). Dieses Modul enthält universelle Domänenobjekte, die von mehreren Komponenten (z. B. `order` und `payment`) verwendet werden. Dies verhindert zirkuläre Abhängigkeiten und stellt sicher, dass Basistypen zentral verwaltet werden.

  #figure(
    caption: [ Zentralisierte Definition in Version 2],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```java
      // com.example.common.domain.OrderStatus.java
      package com.example.common.domain;

      public enum OrderStatus {
          NEW, IN_PROGRESS, DONE, PAID, CANCELED;

          // Enthält auch gemeinsame Logik
          public boolean canTransitTo(OrderStatus to) {
              // Zustandsübergangslogik...
          }
      }

      // Nutzung in verschiedenen Modulen ohne gegenseitige Abhängigkeit:
      // com.example.order.model.OrderItem importiert com.example.common.domain.OrderStatus
      // com.example.payment.service.BillingService importiert com.example.common.domain.OrderStatus
      ```
    ],
  )

  // *Vorteil:*

#heading(
  "E. Qualitäts- und Vollständigkeitsanalyse des Quellcodes (Code Quality & Completeness):",
  level: 4,
  numbering: none,
)
Die KI unterstützte nicht ausschließlich die Refaktorisierung der Code-Struktur, sondern verbesserte die KI auch die Vollständigkeit der Implementierung. Ein typisches Beispiel hierfür ist der MenuService.

+ *Version 1: Einfach und Schnell (18 Zeilen):*

  Diese Version wurde zwar schnell und unkompliziert umgesetzt, umfasst jedoch lediglich 18 Codezeilen und enthält nur eine einzige Methode (listAll) zur Anzeige des Menüs. Wesentliche CRUD-Operationen (Create, Read, Update, Delete) fehlen weitgehend; zudem ist die Dokumentation unvollständig bzw. nicht vorhanden.

  #figure(
    caption: [ MenuService in Version 2],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```java
      // qr-restaurant-backend/src/main/java/com/example/service/MenuService.java
      package com.example.service;

      import com.example.entity.MenuItem;
      import jakarta.enterprise.context.ApplicationScoped;
      import java.util.List;

      @ApplicationScoped
      public class MenuService {

          public List<MenuItem> listActive() {
              return MenuItem.list("active", true);
          }
      }
      ```
    ],
  )

+ *Version 2: Optimieren (128 Zeilen ):*

  In dieser Version unterstützte die KI den Entwickler dabei, den Umfang des Codes auf 128 Zeilen zu erweitern und die Implementierung deutlich zu vervollständigen. Insgesamt wurden sieben Methoden bereitgestellt, darunter Create, Update, Delete, Toggle Status sowie Soft Delete. Darüber hinaus ergänzte die KI automatisch eine konsistente Fehlerbehandlung (z. B. durch NotFoundException), aktualisierte Audit-Felder bzw. -Logs (createdAt, updatedAt) und fügte eine entsprechende Javadoc-Dokumentation hinzu.

  #block(fill: luma(240), inset: 8pt, radius: 4pt)[
    ```java
          // qr-restaurant-backend-antigravity/src/.../menu/service/MenuService.java
    package com.example.menu.service;

    import com.example.menu.model.MenuItem;
    import com.example.menu.repository.MenuItemRepository;
    import com.example.menu.rest.CreateMenuItemRequest;
    import com.example.menu.rest.UpdateMenuItemRequest;
    import jakarta.enterprise.context.ApplicationScoped;
    import jakarta.inject.Inject;
    import jakarta.transaction.Transactional;
    import jakarta.ws.rs.NotFoundException;

    @ApplicationScoped
    public class MenuService {

        @Inject
        MenuItemRepository menuItemRepository;  // ✅ Repository Pattern

        public List<MenuItem> listActive() {
            return menuItemRepository.listActive();
        }

        // ===== Manager Methods =====

        /**
         * List all menu items with optional filtering
         */
        public List<MenuItem> listAll(String category, Boolean active) {
            if (category != null && active != null) {
                return MenuItem.find("category = ?1 and active = ?2", category, active).list();
            } else if (category != null) {
                return MenuItem.find("category", category).list();
            } else if (active != null) {
                return MenuItem.find("active", active).list();
            }
            return MenuItem.listAll();
        }

        /**
         * Find menu item by ID
         */
        public MenuItem findById(Long id) {
            MenuItem item = menuItemRepository.findById(id);
            if (item == null) {
                throw new NotFoundException("Menu item not found: " + id);
            }
            return item;
        }

        /**
         * Create new menu item
         */
        @Transactional
        public MenuItem create(CreateMenuItemRequest request) {
            MenuItem item = new MenuItem();
            item.name = request.name;
            item.category = request.category;
            item.price = request.price;
            item.description = request.description;
            item.imageUrl = request.imageUrl;
            item.active = request.active != null ? request.active : true;

            if (request.tags != null) {
                item.tags.addAll(request.tags);
            }

            item.createdAt = OffsetDateTime.now();
            item.updatedAt = OffsetDateTime.now();

            item.persist();
            return item;
        }

        /**
         * Update existing menu item
         */
        @Transactional
        public MenuItem update(Long id, UpdateMenuItemRequest request) {
            MenuItem item = findById(id);

            if (request.name != null) item.name = request.name;
            if (request.category != null) item.category = request.category;
            if (request.price != null) item.price = request.price;
            if (request.description != null) item.description = request.description;
            if (request.imageUrl != null) item.imageUrl = request.imageUrl;
            if (request.active != null) item.active = request.active;

            if (request.tags != null) {
                item.tags.clear();
                item.tags.addAll(request.tags);
            }

            item.updatedAt = OffsetDateTime.now();
            return item;
        }

        /**
         * Toggle menu item active status
         */
        @Transactional
        public MenuItem toggleStatus(Long id, Boolean active) {
            MenuItem item = findById(id);

    ```
  ]

#figure(
  caption: [Vollständiger MenuService in Version 2 ],
  supplement: [Listing],
  kind: raw,
  block(fill: luma(240), inset: 8pt, radius: 4pt)[
    ```java
            item.active = active;
            item.updatedAt = OffsetDateTime.now();
            return item;
        }

        /**
         * Soft delete menu item (set active=false)
         */
        @Transactional
        public void softDelete(Long id) {
            MenuItem item = findById(id);
            item.active = false;
            item.updatedAt = OffsetDateTime.now();
        }
    }
    ```
  ],
)

#heading("F. Zwischenfazit:", level: 4, numbering: none)

Die Umstellung auf die von der KI vorgeschlagene Architektur führte zu einer signifikanten Verbesserung der Codequalität und Wartbarkeit.

- *Verbesserungen in Version 2*:
  - Klare Trennung von Verantwortlichkeiten durch *Repository Pattern* und *Dependency Injection*.
  - Zentralisierte Domänenlogik verhindert zirkuläre Abhängigkeiten.
  - Vollständige Implementierung von CRUD-Operationen und Sicherheitsmechanismen (z.B. Soft Delete).

- *Zeiteffizienz & Produktivität*:
  - *Manuelle Entwicklung (Version 1)*: Ca. *3 Arbeitstage*. Das Ergebnis war funktional, aber architektonisch Mangelhaft ("Dirty Code") und schwer testbar.
  - *KI-Optimierung (Version 2)*: Ca. *30 Minuten*. Die KI analysierte den bestehenden Code und generierte Refactoring-Vorschläge sowie vollständigen Code, der Best Practices entsprach.
  - *Einsparung*: Ohne KI-Unterstützung hätte der manuelle Refactoring-Prozess und die Bereinigung des Codes geschätzt *weitere 2 Arbeitstage* in Anspruch genommen.

Die KI fungierte hier nicht nur als Werkzeug zur Codegenerierung, sondern als *Senior-Mentor*, der architekturelle Schulden sofort identifizierte und behob.

Es ist jedoch wichtig anzumerken, dass das optimierte Ergebnis der KI nicht bereits in der allerersten Version perfekt war ("Zero-Shot"), sondern mehrere Iterationsschleifen erforderte, um diesen Reifegrad zu erreichen. Die spezifischen Herausforderungen und der iterative Dialog mit der KI werden in Kapitel *4.4 Herausforderungen und Grenzen* detailliert analysiert.

=== Frontend
Dieser Abschnitt dokumentiert die technische Umsetzung sowie die Unterschiede in der Struktur und in der Implementierung zwischen der ursprünglichen Frontend-Version (Version 1) und der KI-gestützten Version (Version 2). Analog zum Backend werden auch hier zwei Versionen gegenübergestellt. Der Vergleich fokussiert sich auf die Verzeichnis- bzw. Ordnerstruktur sowie Unterschiede auf Code-Ebene, um die Auswirkungen der jeweiligen Entwicklungsansätze nachvollziehbar darzustellen.

#heading("A. Projektstruktur (Visual Comparison):", level: 4, numbering: none)

+ *Version 1: flache Struktur (Flat):*

  Die Struktur ist insgesamt sehr flach und für Einsteiger zunächst einfach umzusetzen sowie schnell nachvollziehbar. Allerdings werden `lib/` und wiederverwendbare Module kaum genutzt, während UI, API-Logik und Typen direkt in `+page.svelte` vermischt sind, was Wartbarkeit und Testbarkeit erschwert. Zudem deutet die duplizierte Logik zwischen menu und order auf fehlende Wiederverwendung hin.

  #figure(
    caption: [Dateistruktur in Version 1 (Schichtenarchitektur)],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```bash
      src/
      ├── lib/
      │   ├── server/
      │   └── index.ts        # Leer
      ├── routes/
      │   ├── menu/
      │   │   └── +page.svelte  #  Enthält UI, API-Aufrufe und Typdefinitionen
      │   ├── order/
      │   │   └── +page.svelte  #  Dupliziert Logik aus „menu“
      │   └── kitchen/
      │       └── +page.svelte  #  Enthält 100 % der Küchenlogik (SSE + UI)
      ```
    ],
  )


+ *Version 2: mehrschichtige Struktur (multi-layer):*

  Die Struktur ist mehrschichtig (layered) und deutlich besser modularisiert als die flache Variante. Gemeinsame Funktionalitäten sind sinnvoll in `lib/` gebündelt: eine zentrale API-Schicht (`api.ts`), globales State-Management (`cart.ts`), wiederverwendbare UI-Komponenten (`components/`) sowie Services für Business-Logik. Dadurch werden Wiederverwendung, Wartbarkeit und Testbarkeit verbessert. Gleichzeitig bleibt die Verantwortung der `+page.svelte` Dateien klar abgegrenzt (API-Aufruf und UI-Rendering), was die Übersicht erhöht.

  #figure(
    caption: [Dateistruktur in Version 1 (Schichtenarchitektur)],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```bash
      src/
      ├── lib/
      │   ├── api.ts           # Zentrale API-Schicht (für die gesamte App wiederverwendbar)
      │   ├── cart.ts          # Globaler Zustand (Svelte Store)
      │   ├── components/      # Wiederverwendbare UI-Bausteine
      │   │   ├── kitchen/
      │   │   │   ├── OrderCard.svelte
      │   │   │   └── OrderColumn.svelte
      │   │   └── CartDrawer.svelte
      │   └── services/        # Business-Logik (z. B. Promotion, Tisch-Session)
      ├── routes/
      │   ├── menu/
      │   │   └── +page.svelte  # Ruft nur die API auf und rendert die UI
      │   └── staff/
      │       └── kitchen/       # Importiert Komponenten aus `lib`

      ```
    ],
  )

#heading("B. Detaillierte Unterschiede auf Code-Ebene (Code Level Comparison):", level: 4, numbering: none)
+ *Verwaltung von Typdefinitionen (Type Definitions):*
  - *Version 1* :
    #figure(
      caption: [`routes/menu/+page.svelte` in Version 1],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        // Dieser Typ existiert nur lokal
        type MenuItem = {
          id: number;
          name: string;
          price: number; // Nicht synchron mit dem Backend, falls das Backend einen String liefert
        };
        ```
      ],
    )

    Typen werden in einzelnen Dateien wiederholt lokal definiert. Dadurch entsteht Redundanz: Wenn das Backend ein Feld umbenennt (z. B. `active → isActive`), müssen die Anpassungen in mehreren Dateien durchgeführt werden. Das erhöht den Aufwand und das Risiko, dass Stellen übersehen werden. Zusätzlich besteht die Gefahr von Typabweichungen, z. B. wenn das Backend `price` als `string` liefert, die UI aber `number` erwartet.

  - *Version 2* :
    #figure(
      caption: [`lib/api.ts ` in version 2 ],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        // Einmal definieren, überall verwenden
        export type MenuItem = {
          id: number;
          name: string;
          price: number;
          active: boolean;
          description?: string; //  Optionales Feld, das in Version 1 fehlte
        };

        ```
      ],
    )

    Typen werden zentral (Single Source of Truth definiert) und anschließend in der gesamten Anwendung importiert. Dadurch müssen Änderungen am Datenmodell nur an einer Stelle vorgenommen werden, was die Konsistenz erhöht und Refactorings deutlich vereinfacht. Wird im Backend beispielsweise `active in isActive` umbenannt, genügt eine Anpassung des zentralen Typs (z. B. in `lib/api.ts`); bestehende Imports bleiben unverändert und TypeScript macht Abweichungen unmittelbar sichtbar. Zudem lassen sich Validierungen und Normalisierungen (etwa das zuverlässige Parsen von `price` zu `number`) zentral implementieren, ohne Logik über mehrere UI-Dateien hinweg zu duplizieren.

+ *API-Aufruf (fetch Data):*
  - *Version 1* :
    #figure(
      caption: [fetch Data in version 1 ],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        // Hardcodiertes localhost
        const response = await fetch('http://localhost:8080/api/menu');
        menuItems = await response.json();

        ```
      ],
    )

    Die URL ist direkt im UI hardcodiert und es gibt keine zentrale Fehlerbehandlung. Dadurch wird das Deployment in reale Umgebungen erschwert (z. B. Wechsel von localhost auf einen Server).

  - *Version 2* :
    #figure(
      caption: [fetch Data and Error handling in version 2 ],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        import { fetchMenu } from '$lib/api';
        // Die URL wird aus Umgebungsvariablen (Konfiguration) übernommen; die Fetch-Funktion behandelt Fehler wie 401/500 zentral
        try {
            menuItems = await fetchMenu();
        } catch (error) {
            // Der Error-State wird in der UI automatisch angezeigt
        }
        ```
      ],
    )

    Der API-Aufruf wird über eine Service-Schicht (`lib/api`) gekapselt. Die Basis-URL wird aus Konfiguration bzw. Umgebungsvariablen gelesen, und typische Fehlerfälle (z. B. 401/500) werden einheitlich behandelt. Die UI muss lediglich Fehler abfangen und einen passenden Error-State anzeigen.

+ *Real-time-Verarbeitung (SSE):*
  - *Version 1* :
    #figure(
      caption: [`routes/kitchen/+page.svelte` in version 1 ],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        function connectToStream() {
        // Hardcodierte URL
        eventSource = new EventSource('http://localhost:8080/kitchen/order-items/stream');
        eventSource.onmessage = (event) => {
          // JSON wird inline geparst; bei Fehlern -> Crash oder stilles Scheitern
          const data = JSON.parse(event.data);
          // Merge-Logik ist mit der Verbindungslogik vermischt
          // ...
          };
        }

        ```
      ],
    )

    Die SSE-Logik ist direkt in die Page-Komponente eingebettet. Fällt die Verbindung aus, muss der User häufig manuell neu laden (F5). Zudem wird JSON inline geparst, was bei Parse-Fehlern leicht zu Abstürzen oder „silent fails“ führen kann. Verbindungslogik und Datenverarbeitung sind dabei vermischt.

    - *Version 2* :
    #figure(
      caption: [`lib/api.ts` in version 2 ],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
          // Gemeinsame Funktion; verarbeitet UI-spezifische Logik über Callbacks
          export function connectKitchenStream(onNewOrder, onError) {
          const eventSource = new EventSource(`${API_BASE_URL}/kitchen/order-items/stream`);

          eventSource.onmessage = (event) => {
            try {
              const order = JSON.parse(event.data);
              onNewOrder(order); // Callback triggert UI-Update
            } catch (e) {
              console.error('Parse-Fehler', e);
            }
          };

          // Auto-Reconnect-Logik
          if (onError) {
            eventSource.onerror = (e) => {
              console.error('SSE-Fehler', e);
              setTimeout(() => connectKitchenStream(onNewOrder, onError), 5000); // erneuter Versuch nach 5 s
            };
          }
        }
        ```
      ],
    )
    Die Verbindung wird in eine wiederverwendbare Funktion (`connectKitchenStream`) ausgelagert. Die UI-Logik wird über Callbacks getrennt behandelt, und bei Verbindungsabbrüchen sorgt ein Auto-Reconnect-Mechanismus für eine robustere Laufzeitstabilität.

#heading("F. Zwischenfazit:", level: 4, numbering: none)
Die KI-gestützte Überarbeitung des Frontends führte zu einer besseren Modularisierung und Wartbarkeit: API-Zugriffe, State-Management und wiederverwendbare UI-Komponenten wurden in `lib/` zentralisiert, wodurch Duplikation reduziert und die Verantwortlichkeiten klarer getrennt wurden. Der Entwicklungsaufwand betrug ca. *3 Arbeitstage* in Version 1; die Optimierung durch die KI benötigte ca. *2 Stunden*. Ohne KI-Unterstützung wäre für die Qualitätsverbesserung voraussichtlich ein zusätzlicher *1 Arbeitstag* erforderlich gewesen.
Fehler und Grenzen der KI-unterstützten Umsetzung werden in Kapitel 4.4 behandelt.

== Workflow 2: „KI zuerst – Mensch danach“ (AI → Human Debugging)

Hier generierte die KI zunächst den Entwurf bzw. den initialen Quellcode. Anschließend prüfte der Entwickler die Ergebnisse systematisch, bewertete sie und korrigierte sie bei Bedarf, um Korrektheit, Codequalität und die Erfüllung der Anforderungen sicherzustellen.

=== Anwendungsumfang der Features und Bewertungskriterien
Im Folgenden werden der *Anwendungsumfang* sowie die *Bewertungskriterien* für die nach Workflow 2 entwickelten Funktionalitäten festgelegt.

+ *Anwendungsumfang (Features):*
  - *Backend*:
    - *Promotion Engine*: Abbildung von Rabattregeln und Anwendungsbedingungen.
    - *Staff Management*: Basis-CRUD für Mitarbeitende inklusive Rollen/Status.
    - *Revenue Reports*: Aggregation und Abfrage von Umsatzdaten nach Zeitraum.
  - *Frontend (Manager UI)*:
    - *Menu*: Verwaltung von Artikeln und Sichtbarkeitsstatus.
    - *Bills*: Übersicht zu Bestellungen/Rechnungen und Zahlungsstatus.
    - *Employees*: Verwaltung von Mitarbeitenden (Liste, Status).
    - *Reports*: Visualisierung von Umsatz- und Kennzahlenberichten.
    - *Promotion*: Pflege und Konfiguration von Promotions.

+ *Bewertungskriterien:*
  // - *Funktionalität*:Erfüllung der Anforderungen und Korrektheit der Logik.
  // - *Lesbarkeit*: Struktur, Konsistenz und Wartbarkeit des Codes.
  // - *Fehlerbehandlung*: Standardisierte und konsistente Behandlung von Fehlern und Ausnahmen.
  // - *Performance*: Auswirkungen auf Laufzeit und Datenzugriffe, insbesondere bei Datenbankabfragen und algorithmischer Komplexität.
  //

  KI-generierten Code wird nach folgenden Kriterien bewertet:
  - *Functionality*: Erfüllt die Anforderungen und liefert korrekte Ergebnisse.
  - *Readability*: Lesbarkeit, Struktur und Maintainability des Codes.
  - *Error Handling*: Exception Management und konsistente Fehlerrückgaben.
  - *Performance*: Effizienz, Overfetching-Vermeidung und Optimierungsgrad.
  - *Best Practices*: Einsatz geeigneter Design Patterns, Standards und idiomatischer Lösungen.
  - *Testing*: Testbarkeit (z. B. Mockbarkeit, Separation of Concerns, Vorhandensein geeigneter Test-Seams).

  *Bewertungsskala*: 1–5 (1 = unzureichend, 3 = akzeptabel, 5 = sehr gut).
=== Case Study Backend

In diesem Abschnitt wird Workflow 2 anhand ausgewählter Backend-Module als Case Study analysiert. Die Darstellung folgt einem einheitlichen Schema (Ziel, finale Implementierung, Codeauszug und Bewertung nach Abschnitt 4.3.1); Fehler und deren Behebung werden in Abschnitt 4.4 behandelt.

+ *Features 1: Promotion Engine*
  - *Umfang:* ca. 1.500 @loc; zentrale Dateien: `PromotionService.java` (267), `PromotionResource.java` (117) plus Model/DTOs. Die Implementierung liefert einen klaren Service-Ablauf und eine vollständige Schnittstellenstruktur.
  - *Ziel:* Implementierung einer flexiblen Rabattlogik zur Anwendung von Promotions auf Bills inkl. Persistierung der aktualisierten Beträge. Fokus liegt auf korrekter Berechnung und stabiler Integration in den Backend-Flow.
  - *Codebeispiel 1:* (`applyPromotionToBill()`):
    #figure(
      caption: [Anwenden einer Promotion auf eine Rechnung (Auszug aus PromotionService)],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```java
        @Transactional
        public Bill applyPromotionToBill(Long billId) {
            Bill bill = billRepository.findById(billId);
            if (bill == null) {
                throw new IllegalArgumentException("Bill not found: " + billId);
            }

            // Calculate discount based on current bill state
            CalculationResult result = calculateDiscount(bill);

            // Update bill with discount and recalc total
            bill.discountAmount = result.totalDiscount;
            if (bill.subtotal != null) {
                bill.totalAmount = bill.subtotal.subtract(bill.discountAmount);
            }

            // Ensure total is not negative
            if (bill.totalAmount.compareTo(BigDecimal.ZERO) < 0) {
                bill.totalAmount = BigDecimal.ZERO;
            }

            billRepository.persist(bill);

            // Force initialize lazy collections to avoid serialization errors
            bill.items.forEach(item -> {
                if (item.menuItem != null) {
                    item.menuItem.tags.size();  // ← BUG FIX: Added after debugging
                }
            });
            bill.payments.size();

            return bill;
        }
        ```
      ],
    )

    - *Bewertung nach Kriterien:*
      - *Functionality:* korrekt für Standardfälle; Status-/Edge-Case-Validierung (z. B. „Bill geschlossen“) fehlt.
      - *Readability:* sehr klarer Ablauf (find → calculate → update → persist) und gut nachvollziehbar.
      - *Error Handling:* vorhanden, aber nicht domänenspezifisch (z. B. `IllegalArgumentException` statt `NotFoundException`).
      - *Performance:* Risiko von Overfetching/N+1 durch Lazy-Loading-Workaround (`tags.size()`/`payments.size()`). Details und Behebung siehe Abschnitt 4.4.
      - *Best Practices:* Workaround ist nicht idiomatisch; DTO-Mapping oder `JOIN FETCH` wäre sauberer.
      - *Testing:* durch Repository-Zugriffe grundsätzlich testbar, aber Lazy-Init-Workaround erschwert saubere Isolation.

    - *Mini-Rating (Skala 1–5):*
      #figure(
        caption: [Bewertung des applyPromotionToBill() ],
        kind: table,
        table(
          columns: (auto, auto, auto, auto, auto, auto, auto),
          inset: 10pt,
          align: horizon,
          table.header([*Func.*], [*Read.*], [*Err.*], [*Perf.*], [*BestP.*], [*Testing*], [*Overall*]),
          [4], [5], [3], [2], [3], [3], [3.3],
        ),
      )

  - *Codebeispiel 2 (komplexe Business-Logik):* `calculateDiscount()`:

    #figure(
      caption: [Rabatt berechnen (Auszug aus PromotionService)],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```java
        public CalculationResult calculateDiscount(Bill bill) {
            List<Promotion> activePromos = listActive();
            if (activePromos.isEmpty() || bill.items == null || bill.items.isEmpty()) {
                return new CalculationResult(BigDecimal.ZERO, List.of());
            }

            BigDecimal totalDiscount = BigDecimal.ZERO;
            List<Promotion> appliedPromotions = new ArrayList<>();

            for (Promotion promo : activePromos) {
                boolean applies = false;

                if (promo.scope == PromotionScope.GLOBAL) {
                    applies = true;
                } else if (promo.scope == PromotionScope.TABLE && bill.table != null) {
                    applies = promo.targets.stream()
                        .anyMatch(t -> t.targetType.equals("TABLE")
                            && t.targetValue.equals(bill.table.code));
                } else if (promo.scope == PromotionScope.ITEM) {
                    applies = bill.items.stream()
                        .anyMatch(billItem -> promo.targets.stream()
                            .anyMatch(t -> t.targetType.equals("ITEM")
                                && t.targetValue.equals(billItem.menuItem.id.toString())));
                }
                if (!applies) continue;

                BigDecimal promoDiscount = calculateSingleDiscount(bill.subtotal, promo);
                totalDiscount = totalDiscount.add(promoDiscount);
                appliedPromotions.add(promo);
            }

            return new CalculationResult(totalDiscount, appliedPromotions);
        }
        ```
      ],
    )

    - *Bewertung nach Kriterien:*
      - *Functionality:* funktioniert für Standardfälle, aber fehlende Regeln/Validierungen (z. B. Priorisierung, Begrenzung >100% Rabatt).
      - *Readability:* grundsätzlich nachvollziehbar; Scope-Checks sind strukturiert.
      - *Error Handling:* potenzielle @NPE -Risiken (z. B. `billItem.menuItem.id`); keine robuste Validierung.
      - *Performance:* verschachtelte Streams/Loops (potenziell `O(n²)–O(n³)`) ohne Caching.
      - *Best Practices:* Magic Strings ("`TABLE`", "`ITEM`") sollten Enums/Konstanten sein; `listActive()` ohne Caching/Optimierung.
      - *Testing:* Logik ist testbar, aber ohne klare Abgrenzung (z. B. Caching/Lookups) steigt Testaufwand für Randfälle.

    - *Mini-Rating (Skala 1–5):*
      #figure(
        caption: [Bewertung des calculateDiscount()],
        kind: table,
        table(
          columns: (auto, auto, auto, auto, auto, auto, auto),
          inset: 10pt,
          align: horizon,
          table.header([*Func.*], [*Read.*], [*Err.*], [*Perf.*], [*BestP.*], [*Testing*], [*Overall*]),
          [3], [4], [2], [1], [2], [2], [2.3],
        ),
      )

  - *Codebeispiel 3 (REST API):* `PromotionResource`

    #figure(
      caption: [PromotionResource],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```java
         @POST
        @Path("/{id}/targets")
        public Response addTargets(@PathParam("id") Long id, List<String> targetIds) {
            try {
                promotionService.addTargets(id, targetIds);
                return Response.ok().build();
            } catch (IllegalArgumentException e) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
        }

        @PATCH
        @Path("/{id}/status")
        public Response toggleStatus(@PathParam("id") Long id, boolean isActive) {
            boolean success = promotionService.toggleStatus(id, isActive);
            if (!success)
                return Response.status(Response.Status.NOT_FOUND).build();
            return Response.ok().build();  // ← BUG: Empty response!
        }

        ```
      ],
    )

    - *Bewertung nach Kriterien:*
      - *Functionality:* grundlegende Endpunkte vorhanden, aber Integrationsproblem durch leere Responses (Frontend erwartet JSON).
      - *Readability:* sehr klar und kompakt.
      - *Error Handling:* zu generisch (alle `IllegalArgumentException` → 404), fehlende Validierung (null/empty `targetIds`, `isActive`).
      - *Performance:* unkritisch (einfache REST-Aufrufe)
      - *Best Practices:* Response Body/Audit Logging fehlen bei Statusänderungen; Statuscodes sollten differenzierter sein (400 vs 404).
      - *Testing:* API-Tests sind möglich, allerdings müssen Response-Contracts (Body/DTO) klar definiert werden.

    - *Mini-Rating (Skala 1–5):*
      #figure(
        caption: [Bewertung des PromotionResource],
        kind: table,
        table(
          columns: (auto, auto, auto, auto, auto, auto, auto),
          inset: 10pt,
          align: horizon,
          table.header([*Func.*], [*Read.*], [*Err.*], [*Perf.*], [*BestP.*], [*Testing*], [*Overall*]),
          [3], [5], [2], [4], [2], [3], [3.2],
        ),
      )

+ *Features 2: Staff Management*

  - *Umfang:* ca. 800 Zeilen Code.
  - *Artefakte:* `StaffService.java`, `StaffResource.java`, `AuthService.java`.
  - *Ziel:* Verwaltung von Mitarbeitenden inkl. Rollen/Status (CRUD) sowie Authentifizierung mit sicherer Passwortverarbeitung.

  - *Codebeispiel 1:* `createStaff` in `StaffService`
    #figure(
      caption: [Passwort-Hashing beim Erstellen von Mitarbeitenden],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```java
        @Transactional
        public Staff createStaff(CreateStaffRequest request) {
            Staff staff = new Staff();
            staff.username = request.username;
            // Simples BCrypt Hashing ohne Pepper
            staff.passwordHash = BCrypt.hashpw(request.password, BCrypt.gensalt());
            staff.role = request.role;
            staff.active = true;
            staff.createdAt = OffsetDateTime.now();

            staffRepository.persist(staff);
            return staff;
        }
        ```
      ],
    )

  - *Bewertung:*
    - *Functionality:* Grundfunktion vorhanden, jedoch fehlen zentrale Validierungen (z. B. Unique Username, Passwortregeln).
    - *Readability:* Sehr klar und kompakt, gut nachvollziehbar.
    - *Error Handling:* unzureichend, da Duplicate-Username und Validierungsfehler nicht als definierte Exceptions behandelt werden
    - *Performance::* : angemessen; BCrypt ist bewusst rechenintensiv, für Passwort-Hashing jedoch korrekt gewählt.
    - *Best Practices:* Hashing mit Salt ist korrekt; Rückgabe der Entity (inkl. `passwordHash`) ist jedoch ein Anti-Pattern.
    - *Testing:* grundsätzlich testbar; ohne Validierungslogik fehlen jedoch klare Testfälle für negative Szenarien (Duplicate/Weak Password).

    #figure(
      caption: [Bewertung: Staff Creation],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Func.*], [*Read.*], [*Err.*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
        [3], [5], [2], [4], [3], [3], [3.3],
      ),
    )

  - *Codebeispiel 2:*`verifyPassword` in `AuthService`
    #figure(
      caption: [Authentifizierungs-Helper],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```java
        public java.util.Optional<Staff> verifyPassword(String username, String password) {
            return staffRepository.findByUsername(username)
                    .filter(staff -> staff.active) // Only allow active staff
                    .filter(staff -> BcryptUtil.matches(password, staff.passwordHash));
        }
        ```
      ],
    )

  - *Bewertung:*
    - *Functionality:* Login-Check funktioniert und berücksichtigt `active`-Status.
    - *Readability:* Gut; `Optional`/`filter` erzeugt klaren, deklarativen Ablauf.
    - *Error Handling:* keine differenzierte Fehlerausgabe (z. B. „nicht gefunden“ vs. „inaktiv“ vs. „falsches Passwort“), wodurch Debugging/Monitoring erschwert wird.
    - *Performance:* grundsätzlich akzeptabel; dennoch besteht ein potenzielles Risiko durch frühes Beenden bei „User not found“ (Timing-Aspekt).
    - *Best Practices:* Rückgabe der kompletten Entity (inkl. Hash) ist kritisch; zudem fehlen Rate Limiting/Lockout-Mechanismen gegen Brute Force.
    - *Testing:* gut testbar (Repository mockbar); zusätzliche Security-Tests (Rate Limit, Lockout) sind jedoch nicht abgedeckt.

    #figure(
      caption: [Bewertung: Authentication Helper],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Func.*], [*Read.*], [*Err.*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
        [4], [5], [2], [3], [2], [4], [3.3],
      ),
    )

+ *Features 3: Revenue Reports (KI-generiert)*

  - *Umfang:* ca. 300 Zeilen Code.
  - *Artefakte:* `RevenueReportService.java` sowie Reporting-DTOs.
  - *Ziel:* Bereitstellung von Umsatzkennzahlen (Summary, Category Breakdown) und Auswertungen wie „Top Selling Items“ für einen definierten Zeitraum.

  - *Codebeispiel 1 (`getRevenueSummary` - In-Memory Aggregation):*
    #figure(
      caption: [Umsatz-Aggregation (In-Memory)],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```java
        public RevenueSummaryResponse getRevenueSummary(String period, LocalDate start, LocalDate end) {
            // 1. Load ALL bills from DB
            List<Bill> bills = getPaidBillsInRange(range.start(), range.end());

            // 2. Calculate in Memory (Stream API)
            BigDecimal totalRevenue = bills.stream()
                    .map(bill -> bill.totalAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // 3. Manual Grouping
            List<RevenueByCategory> categoryBreakdown = getRevenueByCategory(bills);

            return new RevenueSummaryResponse(..., totalRevenue, ...);
        }
        ```
      ],
    )

  - *Bewertung:*
    - *Functionality:* Liefert die gewünschten Kennzahlen für kleine Datenmengen korrekt.
    - *Readability:* Gut; der Ablauf ist linear und gut nachvollziehbar, Teilschritte sind delegiert.
    - *Error Handling:* Keine auffälligen Exceptions; fehlende Schutzmechanismen gegen große Datenmengen (Guardrails).
    - *Performance:* kritisch, da alle Bills in den Speicher geladen werden; Risiko von Overfetching/OutOfMemory bei großen Zeiträumen.
    - *Best Practices:* Datenbank wird für Aggregation nicht genutzt (SQL `SUM`/`GROUP BY` wäre idiomatischer und skalierbarer).
    - *Testing:* gut testbar (pure Aggregation), allerdings sind die Tests bei großen Datenmengen nur schwer realistisch zu simulieren, wenn die Logik nicht DB-nah ist.

    #figure(
      caption: [Bewertung: Revenue Summary],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Func.*], [*Read.*], [*Err.*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
        [3], [5], [3], [1], [2], [4], [3.0],
      ),
    )

  - *Codebeispiel 2 (`getTopSellingItems` - manuelles Grouping):*
    #block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```java
      public List<TopSellingItemResponse> getTopSellingItems(String period, LocalDate startDate, LocalDate endDate,
          Integer limit) {
      DateRange range = calculateDateRange(period, startDate, endDate);
      int maxResults = limit != null ? limit : 10;

      List<Bill> paidBills = getPaidBillsInRange(range.start(), range.end());
      List<Long> billIds = paidBills.stream().map(b -> b.id).collect(Collectors.toList());

      if (billIds.isEmpty()) {
          return new ArrayList<>();
      }

      Map<Long, TopSellingItemData> itemMap = new HashMap<>();

      for (Bill bill : paidBills) {
          List<BillItem> items = bill.items;
          for (BillItem item : items) {
              if (item.menuItem == null)
                  continue;

              Long menuItemId = item.menuItem.id;
              BigDecimal netPrice = getNetItemPrice(item, bill);

              itemMap.computeIfAbsent(menuItemId, id -> new

      ```
    ]
    #figure(
      caption: [Top-Seller Ermittlung (Auszug)],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```java
            TopSellingItemData(
                            id,
                            item.menuItem.name,
                            item.menuItem.category)).add(item.quantity, netPrice);
                }
            }

            return itemMap.values().stream()
                    .sorted((a, b) -> Integer.compare(b.totalQuantity, a.totalQuantity))
                    .limit(maxResults)
                    .map(data -> new TopSellingItemResponse(
                            data.menuItemId,
                            data.itemName,
                            data.category,
                            data.totalQuantity,
                            data.totalRevenue,
                            data.orderCount))
                    .collect(Collectors.toList());
        }
        ```
      ],
    )

  - *Bewertung:*
    - *Functionality:* Logik für Aggregation und Ranking ist korrekt; Default für `limit` ist sinnvoll.
    - *Readability:* Gut; imperative Schleifen nachvollziehbar, `computeIfAbsent` sauber eingesetzt.
    - *Error Handling:* grundlegende Null-Checks (z. B. `menuItem` == `null`) sind vorhanden; weitere Eingabevalidierung (z. B. negative Limits) fehlt
    - *Performance:* Problematisch, da Aggregation im Service (O(Bills × Items)) statt in DB erfolgt.
    - *Best Practices:*DB-seitige Aggregation (`GROUP BY, ORDER BY, LIMIT`) wäre effizienter; zudem sollten Lade-/Fetch-Strategien explizit sein, um Lazy-Loading-Fallen zu vermeiden.
    - *Testing:* gut testbar (deterministische Aggregation), jedoch steigt der Aufwand für Integrationstests, wenn Datenmengen realistisch abgebildet werden sollen.

    #figure(
      caption: [Bewertung: Top Selling Items],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Func.*], [*Read.*], [*Err.*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
        [4], [4], [3], [2], [2], [4], [3.2],
      ),
    )
+ *Backend-Zwischenfazit:*

  Insgesamt erzeugte die KI in kurzer Zeit umfangreiche Backend-Module mit hoher Lesbarkeit und einer konsistenten Service-/Resource-Struktur. Besonders stark ist die KI bei der schnellen Erstellung von Boilerplate, DTOs und klaren Kontrollflüssen. Wiederkehrende Schwächen zeigen sich jedoch bei nicht-funktionalen Anforderungen: Performance (z. B. in-memory Aggregation, potenzielle N+1-/Overfetching-Effekte), domänenspezifische Validierung (Status-/Edge-Case-Prüfungen) sowie Sicherheits- und Betriebsaspekte (Logging/Audit, Rate Limiting). Diese Punkte erfordern zusätzliche Review- und Refactoring-Arbeit durch den Entwickler. Konkrete Fehlerbilder und deren Behebung werden in Abschnitt 4.4 systematisch analysiert.


  #figure(
    caption: [Backend-Entwicklungsaufwand (Workflow 2)],
    kind: table,
    table(
      columns: (2.5fr, 1fr, 1fr, 1fr, 0.8fr),
      inset: 8pt,
      align: horizon,
      table.header([*Scope*], [*AI-Gen*], [*Review/Debug*], [*Gesamtzeit*], [*Bugs*]),
      [Backend (Promotion Engine, Staff Mgmt, Revenue Reports)], [3,5 h], [4,5 h], [8,0 h], [8],
    ),
  )


  // #figure(
  //   caption: [Zusammenfassung der drei Backend-Features (Workflow 2)],
  //   kind: table,
  //   table(
  //     columns: (1.5fr, 1fr, 0.8fr, 1fr, 1fr, 1fr, 0.5fr),
  //     inset: 6pt,
  //     align: horizon,
  //     table.header([*Feature*], [*Complexity*], [*LOC*], [*AI-Gen.*], [*Debug.*], [*Gesamt*], [*Bug*]),
  //     [Promotion Engine], [High], [1.500], [2,0 h], [3,8 h], [5,8 h], [4],
  //     [Staff Management], [Medium], [800], [1,0 h], [~0,51 h\*], [~1,51 h], [2],
  //     [Revenue Reports], [Medium], [300], [0,5 h], [~0,19 h\*], [~0,69 h], [2],
  //     table.hline(),
  //     [*Summe*], [], [*2.600*], [*3,5 h*], [*4,5 h*], [*8,0 h*], [*8*],
  //   ),
  // )

=== Case Study Frontend

Dieser Abschnitt analysiert die im Workflow 2 (KI-Zuerst) entwickelte Manager-Oberfläche (Dashboard: Menu, Bills, Employee, Report, Promotions). Der Fokus liegt auf der finalen, bereinigten Version; typische Integrationsfehler (Contract-/Type-Mismatches) werden anschließend in Abschnitt 4.4 ausgewertet.

+ *Architekturüberblick und Bewertungsansatz*

  - Die Manager-Features folgen einer Feature-basierten Modulstruktur unter `src/routes/staff/manager/` (Promotions, Menu, Bills, Employee). Backend-Interaktionen werden zentral in `src/lib/managerApi.ts` gekapselt; diese Datei fungiert als typed contract zwischen Frontend und Backend.

  #figure(
    caption: [Dateistruktur in Version 1 (Schichtenarchitektur)],
    supplement: [Listing],
    kind: raw,
    block(fill: luma(240), inset: 8pt, radius: 4pt)[
      ```bash
      svelte-app/
      ├── src/
      │   ├── routes/                 
      │   │   ├── +page.svelte        
      │   │   ├── menu/               
      │   │   │   └── +page.svelte
      │   │   ├── order/              
      │   │   └── staff/              
      │   │       ├── kitchen/        
      │   │       └── manager/        
      │   │           ├── bills/                     # Rechnung verwalten
      │   │           ├── menu/                      # Menus bearbeiten
      │   │           ├── employee/                  # Staff Verwalten
      │   │           ├── promotions/                # Rabatt aktievieren
      │   │           └── reports/                   # Umsatzbericht
      │   │
      │   └── lib/                    
      │       ├── api.ts              
      │       ├── managerApi.ts                      # Extra apis für manager
      │       ├── auth.ts             
      │       ├── components/         
      │       │   ├── kitchen/       
      │       │   ├── manager/        
      │       │   └── common/         
      │       └── stores/             
      │           └── cart.ts         

      ```
    ],
  )

  - *Umfang:* Gesamtumfang ca. 1.850 LOC (API ~520, Svelte ~1330, verteilt auf vier zentrale Manager-Dateien.

  - *Frontend-spezifische Kriterien:* Für die Fallstudie werden vor allem Type *Safety, Maintainability, UX und Robustness* betrachtet (Skala 1–5).

+ *Feature 1: Manager Dashboard*
 - *Ziel:* Das Dashboard soll zentrale Kennzahlen (z. B. Umsatz, Orders, offene Bills, letzte Transaktionen) kompakt darstellen und die Daten effizient laden. Dabei steht eine konsistente Aggregation der Werte im Vordergrund, um die UI einfach zu halten.

 - *Codebeispiel:*

  #figure(
      caption: [getDashboardSummary() (In ManagerApi.ts)],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        export async function getDashboardSummary(): Promise<DashboardStats> {
          try {
            const [todayRevenue, todayOrders, openBills, recentBills] = await Promise.all([
              fetchTotalRevenue('today'),
              fetchTotalOrders('today'),
              fetchOpenBillsCount(),
              fetchRecentBills(5)
            ]);

            return { todayRevenue, todayOrders, openBills, recentBills };
          } catch (error) {
            throw new ManagerApiError(500, 'Failed to fetch dashboard summary');
          }
        }

        ```
      ],
    )

  - *Bewertung:*
    - *Functionality:* liefert konsistente Dashboard-Daten über einen zentralen Aggregationspunkt
    - *Readability:* klarer Ablauf durch `Promise.all` und kompaktes Response-Objekt.
    - *Error Handling:* Basis-Kapselung via `ManagerApiError`, jedoch eher grobgranular.
    - *Performance:* paralleles Laden verbessert Latenz im UI-Kontext.
    - *Best Practices:* saubere Trennung (API-Layer statt Fetch in UI), typisierte Rückgabe (`DashboardStats`). 
    - *Testing:*  Gut mockbar durch isolierten API-Layer, aber Abhängigkeit von `fetchBills()` erschwert Unit-Tests. Integration-Tests erforderlich für vollständige Coverage.

  #figure(
      caption: [Bewertung: getDashboardSummary()],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Func.*], [*Read.*], [*Err.*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
        [4], [4], [3], [3], [4], [3], [3.5],
      ),
    )

+ *Feature 2: Menu Management*
 - *Ziel:* Vollständige CRUD-Operationen für Menüeinträge, inklusive Aktivierung/Deaktivierung und Echtzeitfilterung nach Kategorie und Suchbegriff.

 - *Codebeispiel 1: Reaktive Filterung*

    #figure(
      caption: [Reaktive Filterung in menu/+page.svelte],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        // Reactive filtering logic: Updates automatically when 'items',
        // 'filterCategory', or 'searchTerm' changes
        $: filteredItems = items.filter(item => {
          const matchesCategory = filterCategory === 'ALL' ||
                                  item.category === filterCategory;
          const matchesSearch = item.name.toLowerCase()
                                    .includes(searchTerm.toLowerCase());
          return matchesCategory && matchesSearch;
        });
      ```
      ],
    )

  - *Codebeispiel 2: Sichere Datenübermittlung*
    #figure(
      caption: [handleSave() in menu/+page.svelte],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        async function handleSave() {
          if (!currentItem.name || !currentItem.price || !currentItem.category) {
            alert('Please fill in all required fields');
            return;
          }
          const requestData: CreateMenuItemRequest = {
            name: currentItem.name,
            category: currentItem.category,
            description: currentItem.description || '',
            price: currentItem.price,
            imageUrl: currentItem.imageUrl,
            active: true
          };
          const newItem = await createMenuItem(requestData);
          items = [...items, newItem]; // Optimistic-like local update
          showSuccess('Menu item created successfully');
        }
        ```
      ],
    )

  - *Bewertung:*
    - *Functionality:* Vollständige CRUD-Logik mit simultaner Suche und Filterung. Alle Anforderungen erfüllt (Create, Read, Update, Delete, Toggle Status).
    - *Readability:* Svelte-Reaktivität (`$:`) macht Filterlogik extrem prägnant und selbsterklärend. Kein verschachtelter Callback-Code; direkte, deklarative Logik.
    - *Error Handling:* Try-Catch in allen CRUD-Operationen mit typisierter `ManagerApiError`-Behandlung. Benutzerfreundliche Fehlermeldungen via `showError()`.
    - *Performance:* Client-seitige Filterung ist effizient für kleine bis mittlere Datasets (~100 Items). Bei größeren Mengen wäre Server-side Filtering besser.
    - *Best Practices:* Typisierte Request-Objekte (`CreateMenuItemRequest`), klare Separation zwischen Daten (`items`) und View (`filteredItems`). Einsatz von Spread-Operator für Immutability.
    - *Testing:* Filter-Logik ist pure function → einfach Unit-testbar. CRUD-Operationen gut mockbar durch isolierte API-Calls.

  #figure(
    caption: [Bewertung: Menu Management (Reactive Filtering + handleSave)],
    kind: table,
    table(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      inset: 8pt,
      align: center,
      table.header([*Func.*], [*Read.*], [*Error*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
      [4], [5], [4], [4], [4], [4], [4.2],
    ),
  )

+ *Feature 3*: Bills & Payment Workflow
  - *Ziel:* Anzeige offener Rechnungen, Verarbeitung von Zahlungen (Bar/Karte) und Auto-Refresh für Echtzeit-Updates.

  - *Codebeispiel 1: Auto-Refresh Pattern*

    #figure(
      caption: [Polling in bills/+page.svelte],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        onMount(() => {
          loadData();
          // Auto-refresh data every 5 seconds
          const interval = setInterval(() => {
            if (!isProcessing && !document.hidden) {
              loadData(true); // Silent refresh                             
            }
          }, 5000);
          return () => clearInterval(interval);
        });
        ```
      ],
    )
    - *Codebeispiel 2: Promotion-Integration*
      #figure(
        caption: [handleCalculateDiscount() in bills/+page.svelte],
        supplement: [Listing],
        kind: raw,
        block(fill: luma(240), inset: 8pt, radius: 4pt)[
          ```ts
          async function handleCalculateDiscount(bill: Bill) {
            if (!bill) return;
            isProcessing = true; // Locks UI interactions
            try {
              const result = await promotionService.calculateBillDiscount(bill.id);
              billCalculations.set(bill.id, result);
              billCalculations = new Map(billCalculations); // Trigger Svelte reactivity
              showSuccess('Promotions calculated');
            } catch (e) {
              showError('Failed to calculate promotions');
            } finally {
              isProcessing = false;
            }
          }
          ```
        ],
      )
    - *Bewertung:*
      - *Functionality:*  Vollständige Payment-Verarbeitung (Cash/Card) mit Promotion-Support und Auto-Refresh. Bill-Cancellation funktioniert korrekt.
      - *Readability:* Mit ~540 LOC ist die Datei groß; Mix aus Polling-Logik, State Management (expandedTables, billCalculations) und UI-Event-Handlern erschwert Überblick.
      - *Error Handling:* Try-Catch in allen async-Operationen, konsistente Fehler-Toasts via `showError()`. `isProcessing`-Lock verhindert Race Conditions während Operationen.
      - *Performance:* Auto-Refresh alle 5s ist ineffizient (Network-Overhead). WebSockets oder SSE wären besser. `document.hidden`-Check ist gute Optimierung.
      - *Best Practices:* Backend-Delegation für Promotion-Berechnungen ist korrekt. Verwendung von `Map` für O(1)-Zugriff auf Bill-Calculations ist effizient. `isProcessing`-Lock ist robuste Praxis. 
      - *Testing:* Polling-Logik schwer zu testen (Timer-Abhängigkeit). Manueller Lock-Mechanismus (`isProcessing`) kann Race Conditions bei komplexen Szenarien nicht vollständig verhindern. Integration-Tests erforderlich. 

    #figure(
      caption: [Bewertung: Bills & Payment (Auto-Refresh + Promotion Integration)],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Func.*], [*Read.*], [*Error*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
        [4], [3], [4], [3], [4], [2], [3.3],
      ),
    )

+ *Feature 4*:  Employee Management
    - *Ziel:* CRUD für Mitarbeiterkonten mit Rollen (Manager, Waiter, Kitchen) und Aktivierung/Deaktivierung.

    - *Codebeispiel 1: CRUD-Operationen*

      #block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```ts
        async function handleSave() {
          if (!editingStaff.displayName || !editingStaff.username ||
              !editingStaff.email || !editingStaff.role) {
            alert('Please fill in all required fields');
            return;
          }
          try {
            isSaving = true;
            if (editingStaff.id) {
              // Update existing staff
              const updated = await updateStaffMember(editingStaff.id, {
                username: editingStaff.username,
                displayName: editingStaff.displayName,
                email: editingStaff.email,
                role: editingStaff.role,
                password: editingStaff.password
              });
              staff = staff.map(s => s.id === editingStaff.id ? updated : s);
              showSuccess('Staff member updated successfully');
            } else {
              // Create new staff
              const requestData: CreateStaffRequest = {
                username: editingStaff.username,
                password: editingStaff.password || 'changeme123', // Default password
                displayName: editingStaff.displayName,
                email: editingStaff.email,
                role: editingStaff.role,
                active: true
              };
              const newStaff = await createStaffMember(requestData);
              staff = [...staff, newStaff];
              showSuccess('Staff member created successfully');
            }
            showModal = false;
            editingStaff = {};
          } catch (e) {
            if (e instanceof ManagerApiError) {
              showError(`Failed to save staff: ${e.message}`);
            } else {
              showError('Failed to save staff. Please try again.');
            }
          } finally {
            isSaving = false;
          }
        }
        ```
      ]
      #figure(
      caption: [handleSave() in employee/+page.svelte],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```svelte
      
        ```
      ],
    )
    - *Codebeispiel 2: Rollenbasiertes Styling*

      #figure(
        caption: [Role Badges in employee/+page.svelte],
        supplement: [Listing],
        kind: raw,
        block(fill: luma(240), inset: 8pt, radius: 4pt)[
          ```svelte
          <span class="px-2 py-1 rounded-full text-xs font-medium
              {member.role === 'MANAGER' ? 'bg-purple-100 text-purple-800' :
              member.role === 'KITCHEN' ? 'bg-orange-100 text-orange-800' :
              'bg-blue-100 text-blue-800'}">
              {member.role}
          </span>
          ```
        ],
      )


    - *Bewertung:*
      - *Functionality:* Standard CRUD für Staff-Accounts vollständig implementiert. Rollen-Management (Manager, Waiter, Kitchen) funktioniert korrekt. 
      - *Readability:* Sehr klare, fokussierte Logik. Komponente ist übersichtlich (~380 LOC). Visuelle Rollen-Badges durch bedingte Klassen sind selbsterklärend.
      - *Error Handling:* Konsistente Try-Catch-Blöcke in allen CRUD-Operationen. Typisierte Error-Handling via `ManagerApiError`. User-friendly Feedback via `showError()` und `showSuccess()`.
      - *Performance:* Keine Performance-Probleme erkennbar. Einfache Filterung (Search) ist client-seitig und effizient für kleine bis mittlere Datasets.
      - *Best Practices:* Passwörter werden im Body gesendet (HTTPS required, aber Standard-Praxis). Default-Passwort ("changeme123") ist schwache Sicherheitspraxis. Keine client-seitige Passwort-Validierung (Stärke-Check fehlt). 
      - *Testing:* CRUD-Operationen gut isoliert und mockbar. Rollen-Logik ist einfach Unit-testbar. UI-Tests für Badge-Rendering wären E2E.

    #figure(
      caption: [Bewertung: Employee Management (Role-Based Styling)],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Func.*], [*Read.*], [*Error*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
        [4], [5], [4], [4], [3], [4], [4.0],
      ),
    )
  


+ *Feature 5*: Design & Styling
  - *Ziel:* Modernes, responsives UI ohne dedizierte CSS-Dateien durch Tailwind Utility Classes.

  - *Codebeispiel:*

    #figure(
      caption: [Bottom Navigation in +layout.svelte],
      supplement: [Listing],
      kind: raw,
      block(fill: luma(240), inset: 8pt, radius: 4pt)[
        ```svelte
        <!-- Modern Bottom Navigation Bar -->
        <nav class="relative bg-surface-dark/90 backdrop-blur-sm shadow-lg
                    rounded-full h-16 border border-border-dark
                    flex items-center justify-around">
          <a href="/" class={`nav-link ${activeNav === 'Home'
                              ? 'active text-background-dark'
                              : 'text-text-dark-secondary'}`}>
            <!-- Icon logic -->
          </a>
        </nav>
        ```
      ],
    )

    - *Bewertung:*
      - *Functionality:* Glassmorphism-Effekt funktioniert korrekt; Navigation ist responsiv und visuell ansprechend. Active-State-Highlighting funktioniert
      - *Readability:* Tailwind Utility Classes sind direkt in HTML → gut lesbar, aber lange Klassenlisten können unübersichtlich werden. Keine separaten CSS-Dateien vereinfacht Navigation.
      - *Error Handling:* Nicht anwendbar für statisches Styling.
      - *Performance:* Tailwind's Purge-Mechanismus eliminiert ungenutztes CSS in Production. `backdrop-blur` ist GPU-beschleunigt, aber kann auf älteren Geräten Performance-Probleme verursachen.
      - *Best Practices:* Keine Design-Tokens oder CSS-Variablen → hardcodierte Farben (`text-purple-800`, `bg-blue-100`) schaden Konsistenz und Theme-Wechsel. Utility-First-Ansatz ist moderne Praxis. 
      - *Testing:* Visuelle Regression-Tests (Screenshot-Vergleiche) erforderlich. Keine Unit-Tests für Styling möglich; E2E-Tests für Navigation-Interaktionen nötig.

    #figure(
      caption: [Bewertung: Design & Styling (Glassmorphism Navigation)],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Func.*], [*Read.*], [*Error*], [*Perf.*], [*BestP.*], [*Test*], [*Overall*]),
        [4], [4], [-], [4], [3], [3], [3.6],
      ),
    )

+ *Zwischenfazit*: 
  // Die folgende Tabelle fasst den Entwicklungsaufwand und die Code-Metriken für die Manager-Features zusammen.
  // #figure(
  //   caption: [Feature Metrics: Manager UI (Workflow 2)],
  //   kind: table,
  //   table(
  //     columns: (2fr, 1fr, 1.2fr, 1.2fr, 1fr, 1fr),
  //     inset: 8pt,
  //     align: center,
  //     table.header([*Frontend-Feature*], [*LOC*], [*KI-Gen. (h)*], [*Debug (h)*], [*Gesamt*], [*Bugs*]),
  //     [Dashboard], [~200], [0.2], [0.5], [0.7], [1],
  //     [Menu Management], [~410], [0.3], [0.8], [1.1], [2],
  //     [Bills & Payment], [~540], [0.5], [1.5], [2.0], [4],
  //     [Employee Mgmt.], [~380], [0.3], [0.7], [1.0], [2],
  //     [Promotions], [~530], [1.0], [2.0], [3.0], [3],
  //     [Reports], [~290], [0.2], [0.5], [0.7], [1],
  //     table.cell(colspan: 5, align: right)[*Gesamt:*], [*13*],
  //   ),
  // )
  // *Erkenntnisse:*
  // - *Schnelle Generierung:* AI erzeugte komplette CRUD-Seiten in < 1 Stunde.
  // - *Debug-Overhead:* Debugging benötigte ~3–5× die Generierungszeit (Typ-Mismatches, Contract-Fehler).
  // - *Komplexität:* Bills-Feature hat höchste Komplexität (~540 LOC) und Debug-Zeit (1.5h).
  Die KI erzeugt die Seiten schnell, der Hauptaufwand liegt jedoch im Review/Debug (≈ 3–5× der Generierungszeit). Besonders komplexe Features (z. B. Bills & Payment) treiben Debug-Zeit und Fehlerzahl nach oben.

  #figure(
      caption: [Zeitaufwand und Bugs],
      kind: table,
      table(
        columns: (1fr, 1fr, 1fr, 1fr),
        inset: 8pt,
        align: center,
        table.header([*Bereich*], [*KI-Gen.*], [*Review/Debug*], [*Bugs*]),
        [Manager UI], [~2.5 h], [~6.0 h], [13],
      ),
    )

== Herausforderungen und Grenzen der KI-gestützten Entwicklung

Dieses Kapitel ergänzt die Ergebnisse aus 4.2 und 4.3 um Aspekte, die in den finalen „Clean“-Versionen nur eingeschränkt sichtbar sind: Bug-Muster, Iterationsbedarf und typische Grenzen der KI-Unterstützung. Der Fokus liegt auf Fehlern, die erst im Systemkontext (Persistenz, Contracts, Edge Cases, Datenflüsse zwischen Modulen) auftreten und dadurch messbaren Review-/Debug-Aufwand verursachen.

// === Bug-Kategorien und Messansatz
//   + **
=== Workflow 1 (Mensch zuerst – KI danach):

    In Abschnitt 4.3 wurde gezeigt, dass Künstliche Intelligenz (KI) bei der Optimierung von Quellcode unterstützend eingesetzt werden kann. Um eine saubere und qualitativ hochwertige Endversion zu gewährleisten, ist jedoch eine sorgfältige Überprüfung und Bewertung der von der KI generierten Versionen erforderlich, da KI nicht in jedem Kontext automatisch die optimale Lösung liefert. Die folgenden Beispiele verdeutlichen Fehler, die in früheren KI-generierten Versionen aufgetreten sind.

+ *Backend - Bugs:*
  - *Beispiel 1*: MenuService
    
    - *Bug A* (Data & Persistence): Fehlende `@Transactional-Annotation` in der Methode create(), wodurch Persistenzoperationen nicht zuverlässig ausgeführt wurden.

      #figure(
          caption: [Create function in MenuService],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            // PRE-FINAL BUG: @Transactional fehlt
            public MenuItem create(CreateMenuItemRequest request) {
                MenuItem item = new MenuItem();
                item.createdAt = OffsetDateTime.now();
                item.persist(); // Persistenz/Flush nicht garantiert
                return item;
            }

            ```
          ],
        )


    - *Bug B* (Functional): Fehlerhafte PATCH-Semantik, bei der bestehende Werte unbeabsichtigt durch null überschrieben wurden.
    
      #figure(
          caption: [update function in MenuService],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @Transactional
            public MenuItem update(Long id, UpdateMenuItemRequest request) {
                MenuItem item = menuItemRepository.findById(id);
                item.name  = request.name;   // null überschreibt bestehende Werte
                item.price = request.price;  // null überschreibt bestehende Werte
                item.updatedAt = OffsetDateTime.now();
                return item;
            }

            ```
          ],
        )

      
    
    - *Bug C* (Observability / Functional): Fehlende Audit-Informationen beim Soft Delete, wodurch die Nachvollziehbarkeit von Datenänderungen eingeschränkt war.
    
      #figure(
          caption: [softDelete function in MenuService],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @Transactional
            public void softDelete(Long id) {
                MenuItem item = menuItemRepository.findById(id);
                item.active = false;
                // PRE-FINAL BUG: updatedAt fehlt
            }

            ```
          ],
        )

    - *Bug Count & Debug*:
      - Bugs: 3
      - Debug time: ~0.4h (0.1h + 0.2h + 0.1h)

  - *Beispiel 2*: GuestSessionService
    
    - *Bug A* (Functional): Fehlende Null-Prüfung für `table` und `nickname`, was zu Laufzeitfehlern führte.

      #figure(
          caption: [createForTable function in GuestSessionService],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @Transactional
            public GuestSession createForTable(Table table, String nickname) {
                // PRE-FINAL BUG: kein Check, ob table null sein kann
                GuestSession gs = new GuestSession();
                gs.table = table;
                gs.nickname = nickname; // nickname kann null sein
                guestSessionRepository.persist(gs);
                return gs;
            }


            ```
          ],
        )


    - *Bug B* (Error Handling): Fehlende Zustandsprüfung beim Schließen, wodurch der Fall „bereits geschlossen“ nicht korrekt behandelt wurde.
    
      #figure(
          caption: [close function in GuestSessionService],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @Transactional
            public GuestSession close(Long guestSessionId) {
                GuestSession gs = guestSessionRepository.findById(guestSessionId);
                if (gs == null) throw new NotFoundException("Guest session not found");
                gs.active = false; // PRE-FINAL BUG: kein Guard für !gs.active
                return gs;
            }


            ```
          ],
        )


    - *Bug Count & Debug*:
      - Bugs: 2
      - Debug time: ~0.2h (0.1h + 0.1h)
+ *Frontend - Bugs:*

=== Workflow 2 (KI zuerst – Mensch danach):

In diesem Workflow lässt sich erkennen, dass die Fähigkeit der Künstlichen Intelligenz, auf Basis gegebener Anforderungen schnell und in großer Menge Quellcode zu generieren, besonders ausgeprägt ist. Eine hohe Generierungsgeschwindigkeit bedeutet jedoch nicht zwangsläufig, dass der erzeugte Code stets leicht verständlich und vollständig korrekt ist. Dies führte dazu, dass die Fehlersuche und das Debugging für den Entwickler deutlich komplexer und zeitaufwendiger wurden. Im Folgenden werden die im Workflow 2 identifizierten Bugs dargestellt.


+ *Backend - Bugs:*
  - *Bug #1* (Security / Authorization): Fehlende Autorisierung auf allen geschützten Endpunkten.

    -* Beschreibung*: Dieses Bug betrifft einen kritischen Sicherheitsmangel im Bereich Authorization und wirkt sich auf sämtliche als geschützt vorgesehenen API-Endpunkte aus. Im Backend wurde keine `@RolesAllowed`-Annotation auf irgendeinem Endpunkt implementiert. Die Zugriffskontrolle erfolgte ausschließlich auf Frontend-Ebene durch eine einfache Authentifizierungsprüfung mittels localStorage.

      Dadurch war es für beliebige externe Akteure möglich, bekannte API-Endpunkte direkt aufzurufen und die Frontend-Logik vollständig zu umgehen. Eine serverseitige Autorisierung zur Überprüfung von Benutzerrollen oder Zugriffsrechten war nicht vorhanden, was ein erhebliches Sicherheitsrisiko für das gesamte System darstellte.

    #figure(
          caption: [Eine Beispiel für Resource ohne `@RolesAllowed` ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            // ManagerBillResource.java -  kein authorization (@RolesAllowed)
            @Path("/api/manager/bills")
            @Consumes(MediaType.APPLICATION_JSON)
            @Produces(MediaType.APPLICATION_JSON)
            public class ManagerBillResource {
                
                @POST
                @Path("/{id}/pay")
                @Transactional
                public Bill processPayment(@PathParam("id") Long billId, ...) {
                    // jede kann diese Endpoint aufrufen!
                    billingService.processPayment(billId, ...);
                    return bill;
                }
            }

            ```
          ],
        )

    

     - *Debug-Aufwand*: ca. 4–7 Stunden (Autorisierung (1h), Frontend-Anpassung (2h), Endpunkt-Tests (3h)).
  
  - *Bug 2* (Data & Persistence): LazyInitializationException
    - *Feature* : Bill Management (Payment Module)
    - *Beschreibung*: Bei Bug 2 trat eine LazyInitializationException im Zusammenhang mit den Entitäten Bill Items und Payments auf. Die Ursache lag in der Konfiguration der Collections Bill.items und Bill.payments, welche mittels Hibernate Lazy Loading geladen wurden.

      Zusätzlich bestand ein Problem hinsichtlich der Transaktionsgrenzen: Die Serialisierung des Bill-Objekts durch Jackson erfolgte erst nach dem Abschluss der Datenbanktransaktion. Da JAX-RS die Response-Objekte automatisch serialisiert, wurde beim Zugriff auf die lazy geladenen Collections versucht, auf einen bereits geschlossenen Persistenzkontext zuzugreifen. Dies führte zur genannten Ausnahme und beeinträchtigte die Stabilität der betroffenen Endpunkte. 

     #figure(
          caption: [ LazyInitializationException Bug ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @POST
            @Path("/{id}/close")
            @Transactional
            public Bill closeBill(@PathParam("id") Long billId) {
                billingService.closeBill(billId);
                Bill bill = billRepository.findById(billId);
                return bill;  //  items & payments werden nicht geladet!
            }
            // → Jackson serialize → LazyInitializationException

            // Lösung:
            //  Force load data in transaction before return
            // bill.items.size();      // Trigger: SELECT * FROM bill_items
            // bill.payments.size();   // Trigger: SELECT * FROM payments
            ```
          ],
        )

    - *Debug-Aufwand*: 3-4 Stunden

  - *Bug 3* (Configuration / API Design): Duplicate Endpoint Error
    - *Feature* : Bill Workflow Redesign
    - *Beschreibung*: Im Rahmen des Redesigns des Bill-Workflows trat ein   Duplicate-Endpoint-Fehler auf. Die Ursache lag darin, dass beim Erstellen der neuen Klasse `ManagerBillResource.java` nicht erkannt wurde, dass bereits eine ältere Ressource `BillManagerResource.java` existierte. Beide Klassen deklarierten denselben Pfad `@Path`("/api/manager/bills"), was zu einem Konflikt bei der Endpunkt-Registrierung führte.

      Zusätzlich wurde der Fehler durch eine inkonsistente Benennung der Klassen begünstigt (ManagerBillResource vs. BillManagerResource), wodurch die doppelte Definition während der Entwicklung zunächst unbemerkt blieb.

      #figure(
          caption: [ Duplicate Endpoint Error ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            // File 1: ManagerBillResource.java (neu – korrekter Ort)
            package com.example.manager.rest;

            @Path("/api/manager/bills")
            public class ManagerBillResource { ... }

            // File 2: BillManagerResource.java (alt – falscher Ort)
            package com.example.payment.rest;

            @Path("/api/manager/bills") // DUPLICATE PATH
            public class BillManagerResource { ... }
            // Lösung: Remove-Item "src/main/java/com/example/payment/rest/BillManagerResource.java"

            ```
          ],
        )
    - *Debug-Aufwand*: 0.5 Stunde

  - *Bug 4* (Data & Persistence): Fehlerhafte Spaltenzuordnung für den Status der Tabelle
    - *Feature* : Table Management
    - *Beschreibung*: Im Rahmen der Implementierung des Table-Managements trat ein Fehler im Datenbankschema auf, der auf eine inkonsistente Spaltenzuordnung zwischen Code und Datenbank zurückzuführen war. Konkret wurde das Attribut `status` in der Entität fälschlicherweise auf die Spalte `table_status` gemappt, während das zugrunde liegende Datenbankschema eine Spalte `status` mit der Einschränkung `NOT NULL` vorsah.

      Da Hibernate beim Einfügen neuer Datensätze die Spalte status nicht explizit befüllte, wurde in der Datenbank ein `NULL`-Wert erzeugt, was zu einem SQL-Fehler führte.

      #figure(
          caption: [ Fehlerhafte Spaltenzuordnung ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @Entity
            @Table(name = "tables")
            public class Table extends PanacheEntity {
                
                @Column(name = "table_status", nullable = false, length = 20)
                public String status = "ACTIVE"; //  falsche Spaltenzuordnung
                // DB expects: INSERT INTO tables (..., status, ...) VALUES ...
                // But Hibernate generates: INSERT INTO tables (..., table_status, ...) VALUES ...
                // → Error: status column is NULL!
            }

            // Lösung: @Column(nullable = false, length = 20)
            //          public String status = "ACTIVE"; 

            ```
          ],
        )
    - *Debug-Aufwand*: 1 Stunde
  
  - *Bug 5* (Data & Persistence): LazyInitializationException
    - *Feature* : Promotion Management
    - *Beschreibung*: Im Rahmen der Promotion-Verarbeitung trat erneut eine LazyInitializationException auf. Der Fehler zeigte sich in zwei aufeinanderfolgenden Schritten.

        In der ersten Behebungsphase wurde – analog zu Bug 1 – ausschließlich die Collection `Bill.items` innerhalb der Transaktion initialisiert. Dies erwies sich jedoch als unzureichend, da die automatische Serialisierung durch Jackson eine tiefere Objektstruktur traversierte (`Bill → BillItem → MenuItem → Tags`).

        In der zweiten Phase wurde festgestellt, dass auch die Collection `MenuItem.tags` lazy geladen war und außerhalb der Transaktionsgrenze initialisiert werden sollte, was erneut zu einer Ausnahme führte.

      #figure(
          caption: [ applyPromotionToBill (1. Fix) ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @POST
            @Path("/apply-to-bill/{billId}")
            @Transactional
            public Bill applyPromotionToBill(@PathParam("billId") Long billId) {
                // ... apply promotion logic ...
                Bill bill = billRepository.findById(billId);
                
                bill.items.size();  //  Initialisierung der Items (Fix 1)
                
                return bill;  
                //  Fehler bleibt bestehen:
                // Bill.items[].menuItem.tags → LazyInitializationException
            }
 

            ```
          ],
        )

        #figure(
          caption: [ applyPromotionToBill (2. Fix) ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @POST
            @Path("/apply-to-bill/{billId}")
            @Transactional
            public Bill applyPromotionToBill(@PathParam("billId") Long billId) {
                // ... apply promotion logic ...
                Bill bill = billRepository.findById(billId);
                
                // Vollständige Initialisierung des Objektgraphen
                bill.items.forEach(item -> {
                    if (item.menuItem != null && item.menuItem.tags != null) {
                        item.menuItem.tags.size(); // Force load tags
                    }
                });
                
                return bill;  // Alle benötigten Daten sind initialisiert
            }

            ```
          ],
        )
    - *Debug-Aufwand*: ca. 2 Stunden

  - *Bug 6* (Functional / Data Consistency): Promotion Targets wurden nicht aktualisiert
    - *Feature* : Promotion Management
    - *Beschreibung*: Bei Bug 6 wurde festgestellt, dass bei der Aktualisierung einer Promotion die zugehörigen Targets nicht angepasst wurden. Obwohl über den Endpunkt `PUT /api/promotions/{id}` neue Target-Daten übermittelt wurden, verblieben die bestehenden Target-Einträge unverändert in der Datenbank.

      Die Ursache lag in der Implementierung der Methode `update()` im PromotionService, in der ausschließlich grundlegende Felder der Promotion aktualisiert wurden, während die Verarbeitung des Feldes targets vollständig fehlte. Dadurch entstand eine Inkonsistenz zwischen dem vom Client gesendeten Zustand und dem persistierten Datenbestand.

      #figure(
          caption: [ Promotion Targets wurden nicht aktualisiert ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @PUT
            @Path("/{id}")
            @Transactional
            public Promotion update(@PathParam("id") Long id, UpdatePromotionRequest request) {
                Promotion existing = Promotion.findById(id);
                
                // Update basic fields
                existing.name = request.name;
                existing.discountType = request.discountType;
                existing.discountValue = request.discountValue;
                //  Targets werden nicht aktualisiert
                
                existing.persist();
                return existing;  // Targets behalten den alten Zustand
            }

            // Lösung:
            // Korrekte Aktualisierung der Targets
            // existing.targets.clear();
            // request.targets.forEach(t -> {
            //     PromotionTarget target = new PromotionTarget();
            //     target.targetType = t.targetType;
            //     target.targetId = t.targetId;
            //     existing.targets.add(target);
            // });
            ```
          ],
        )

    - *Debug-Aufwand*: ca. 0.75 Stunden

  - *Bug 7* (API Contract / Error Handling): JSON-Parsing-Fehler durch leeren Response-Body
    - *Feature* : Promotion Management
    - *Beschreibung*: Bei Bug 7 trat ein Fehler beim JSON-Parsing auf, der durch einen leeren Response-Body verursacht wurde. Der Endpunkt `PATCH /api/promotions/{id}/status` lieferte zwar einen HTTP-Status `200 OK`, enthielt jedoch keinen JSON-Inhalt im Response-Body.

      Auf Frontend-Seite wurde die Antwort standardmäßig mittels `response.json()` verarbeitet. Da der Response-Body leer war, führte dieser Aufruf zu einem Laufzeitfehler (`SyntaxError: Unexpected end of JSON input`). Damit bestand eine Inkonsistenz zwischen dem impliziten API-Vertrag und der tatsächlichen Serverantwort.

      #figure(
          caption: [ JSON-Parsing-Fehler ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```java
            @PATCH
            @Path("/{id}/status")
            @Transactional
            public Response toggleStatus(@PathParam("id") Long id, 
                                        @QueryParam("active") Boolean active) {
                Promotion promotion = Promotion.findById(id);
                promotion.isActive = active;
                promotion.persist();
                
                return Response.ok().build();  //  Leerer Response-Body
            }
            // Lösung:
            // return Response.ok(Map.of("isActive", promotion.isActive)).build();
            ```
          ],
        )

    - *Debug-Aufwand*: ca. 0.5 Stunden

  - *Bug 8* (Version Control / Critical Incident): Git-Restore-Vorgang führte zum Verlust wesentlicher Codebestandteile
    - *Feature* : Gesamtes Backend
    - *Beschreibung*: Bei Bug 7 handelte es sich um einen kritischen Vorfall, der durch einen unsachgemäß ausgeführten git restore-Vorgang verursacht wurde. Infolge dieser Aktion wurde der Codebestand auf einen älteren Stand zurückgesetzt, wodurch sämtliche Implementierungen in Workflow 1 und Workflow 2 verloren gingen.

      Der Vorfall führte dazu, dass der Build-Prozess nicht mehr erfolgreich abgeschlossen werden konnte. Insgesamt fehlten mehr als 20 Methoden, was zu einer Vielzahl von Kompilierungsfehlern führte und die Funktionsfähigkeit zentraler Backend-Komponenten vollständig beeinträchtigte.

    - *Wiederherstellung* (Recovery Process): Zur Behebung des Vorfalls wurde ein manueller Wiederherstellungsprozess durchgeführt, der sich auf die bestehende Dokumentation aus Workflow 1 und Workflow 2 stützte. Insgesamt wurden 15 Dateien rekonstruiert und zentrale Funktionalitäten erneut implementiert.

    - *Anmerkung:* Obwohl Bug 8 nicht als klassischer Implementierungsfehler im Quellcode einzustufen ist, wird er in dieser Arbeit bewusst als kritischer Fehlerfall betrachtet. Der Vorfall hatte erhebliche Auswirkungen auf die Funktionsfähigkeit des Gesamtsystems und ist als prozessbedingter Defekt im Entwicklungsworkflow einzuordnen.

    - *Debug-Aufwand*: ca. 3 Stunden

+ *Frontend - Bugs*
   - *Bug 1*(Session Management): Fehlende Aktualisierung der `guestSessionId`
      - *Feature:* Guest Session / Start Page
      - *Beschreibung:* Der Fehler entstand dadurch, dass nach dem Start der Guest-Session die Methode `setTableId()` nicht aufgerufen wurde und die `tableId` somit nicht im `localStorage` gespeichert war. Infolgedessen griffen nachfolgende API-Aufrufe auf einen falschen oder nicht gesetzten Tabellenwert zu.

      #figure(
          caption: [ Fehlende Aktualisierung der `guestSessionId` ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```ts
            // start/[code]/+page.svelte
            if (response.ok) {
              const data = await response.json();
              //  setTableId() wird nicht genutzt für API client
              localStorage.setItem('guestSession', JSON.stringify(data));
              goto('/menu');
            }

            //Lösung: Update    
            // setTableId(data.id);  // localStorage.setItem('qr_restaurant_table_id', data.id)
            ```
          ],
        )

    - *Debug-Aufwand*: ca. 1 Stunden

   - *Bug 2*(Integration / Configuration): Mehrere Integrationsprobleme in der Manager-Oberfläche
      - *Feature:* Manager Dashboard & Pages (3 Issues innerhalb eines Features)
      - *Beschreibung:* Im Rahmen der Implementierung der Manager-Oberfläche traten mehrere Integrationsprobleme auf, die unterschiedliche Ebenen der Frontend-Architektur betrafen. Die Fehler reichten von fehlenden Abhängigkeiten über fehlerhafte Importpfade und Typinkonsistenzen bis hin zu falschen Routing-Konfigurationen sowie unzulässigen Server-Imports im Client-Code.

        Die Häufung dieser Probleme innerhalb eines einzelnen Features führte dazu, dass die betroffenen Manager-Seiten nicht korrekt kompiliert oder ausgeführt werden konnten und somit funktional nicht nutzbar waren.

      #figure(
          caption: [ Fehlerhafte Importpfade (Issue 1) ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```ts
            // BEFORE
            import { mockMenuItems } from '../../lib/mockData';  //  falscher Pfad
            import { MenuItem } from '../../lib/types';          //  falscher Pfad

            // AFTER
            import { mockMenuItems } from '$lib/mockData';  //  SvelteKit-Alias
            import { MenuItem } from '$lib/types';          //  korrekt

            ```
          ],
        )
      
      #figure(
          caption: [ Typinkonsistenzen (Issue 2) ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```ts
            // BEFORE
            export interface MenuItem {
                id: string;        //  Typinkonsistenz
                isActive: boolean; //  Feldname inkorrekt
            }

            // AFTER 
            export interface MenuItem {
                id: number;    //  Backend-form
                active: boolean;
            }

            ```
          ],
        )

      #figure(
          caption: [ Falsche Routen (Issue 3) ],
          supplement: [Listing],
          kind: raw,
          block(fill: luma(240), inset: 8pt, radius: 4pt)[
            ```ts
            // BEFORE
            const navItems = [
                { to: '/manager', label: 'Dashboard' },      //  404
                { to: '/manager/menu', label: 'Menu' },      //  404
            ];

            // AFTER 
            const navItems = [
                { to: '/staff/manager', label: 'Dashboard' },     
                { to: '/staff/manager/menu', label: 'Menu' },
            ];

            ```
          ],
        )


    - *Debug-Aufwand*: ca. 2-3 Stunden

 - *Bug 3* (UI / Data Visualization): Fehlende Y-Achsenbeschriftung in Diagrammen
    - *Feature:* Revenue Reports – Charts
    - *Beschreibung:* Bei Bug 3 traten Darstellungsprobleme in den Diagrammen der Umsatz- und Bestellberichte auf. Die Diagramme enthielten keine Y-Achsenbeschriftung, wodurch die dargestellten Werte nicht interpretierbar waren und die Skalierung unklar blieb.

      Zusätzlich waren die Umsatzbalken teilweise nicht sichtbar oder farblich nicht eindeutig erkennbar. Im Bestelldiagramm fehlten zudem verbindende Linien zwischen den Datenpunkten, was die zeitliche Entwicklung der Bestellmengen erschwerte.

      #figure(
            caption: [ keine Y-Achse in Revenue Chart ],
            supplement: [Listing],
            kind: raw,
            block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
              <!-- Revenue Chart – ohne Y-Achse -->
              <div class="flex-1 flex items-end justify-between gap-2">
                {#each chartData as data}
                  <div class="bg-blue-500 w-full rounded-t-sm" 
                      style="height: {(data.revenue / maxRevenue) * 100}%;">

                    <!--  Keine Y-Achsenbeschriftung -->
                  </div>
                {/each}
              </div>


              ```
            ],
          )
     *Lösung*:
      #block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
              <!-- Revenue Chart - With Y-axis -->
              <div class="flex-1 flex gap-4">
                <!--  Y-axis labels -->
                <div class="flex flex-col justify-between text-xs text-slate-400 pr-2 w-12 text-right">
                  <span>3200</span>
                  <span>2400</span>
                  <span>1600</span>
                  <span>800</span>
                  <span>0</span>
                </div>
                
                <!-- Chart area -->
                <div class="flex-1 flex items-end justify-between gap-2">
                  {#each chartData as data}
                    <div class="bg-blue-500 w-full rounded-t-sm" 
                        style="height: {(data.revenue / maxRevenue) * 100}%; min-height: 4px;">
                      <!--  min-height ensures bars are visible -->
                    </div>
                  {/each}
                </div>
              </div>
              <!-- Order Chart - With connecting lines -->
              <div class="flex-1 flex gap-4">
                <!-- Y-axis -->
                <div class="flex flex-col justify-between text-xs text-slate-400 pr-2 w-12 text-right">
                  <span>120</span>
                  <span>90</span>
                  <span>60</span>
                  <span>30</span>
                  <span>0</span>
                </div>
                
                <!-- Chart with SVG lines -->
                <div class="flex-1 relative">
                  <svg class="absolute top-0 left-0 w-full h-full pointer-events-none">
                    {#each chartData as data, i}
                      {#if i < chartData.length - 1}
                        <!-- SVG connecting lines -->
                        <line 
                          x1="{(i / (chartData.length - 1)) * 100}%" 
                          y1="{100 - (data.orders / maxOrders) * 100}%"
                          x2="{((i + 1) / (chartData.length - 1)) * 100}%" 
                          y2="{100 - (chartData[i + 1].orders / maxOrders) * 100}%"
                          stroke="#a855f7" 
                          stroke-width="2"
                        />
                      {/if}
                    {/each}
                  </svg>
                  <!-- Data points -->
                </div>
              </div>


              ```
            ]
      #figure(
            caption: [ keine Y-Achse in Revenue Chart (Losung) ],
            supplement: [Listing],
            kind: raw,
            block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
            
              ```
            ],
          )

    - *Debug-Aufwand:* ca. 1,5 Stunden

- *Bug 4* (Type / Runtime Error): Inkonsistente Bill-Property im Manager-Dashboard
  - *Feature:* Manager Dashboard
  - *Beschreibung:* Bei Bug 4 trat ein Laufzeitfehler im Manager-Dashboard auf, der durch eine inkonsistente Verwendung von Eigenschaften im `Bill-Objekt` verursacht wurde. Die zugrunde liegende Datenstruktur der Entität `Bill` hatte sich geändert, wobei das frühere Attribut completedOrders durch die Collection items ersetzt wurde.

    Die Funktion `getDashboardSummary()` verwendete jedoch weiterhin die veraltete Eigenschaft `bill.completedOrders`. Da dieses Attribut zur Laufzeit nicht mehr existierte, führte der Zugriff auf eine undefinierte Referenz zu einem Fehler (`Cannot read properties of undefined`).

    #figure(
            caption: [ Inkonsistente Bill-Property ],
            supplement: [Listing],
            kind: raw,
            block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
            // managerApi.ts – getDashboardSummary()
            const todayOrders = todayBills.reduce(
                (sum: number, bill: Bill) => 
                    sum + bill.completedOrders.reduce(  //  veraltete Property
                        (itemSum: number, item: OrderItem) => itemSum + item.quantity, 
                        0
                    ),
                0
            );
            // Error: Cannot read properties of undefined (reading 'reduce')
            //Lösung:
            const todayOrders = todayBills.reduce(
                (sum: number, bill: Bill) => 
                    sum + bill.items.reduce(  //  korrekte Property
                        (itemSum: number, item: BillItem) => itemSum + item.quantity,
                        0
                    ),
                0
            );
              ```
            ],
          )
  - *Debug-Aufwand:* ca. 0,5 Stunden

- *Bug 5* (API Contract / Data Binding): Abweichende Feldnamen in der Umsatzkategorisierung
  - *Feature:* Revenue Reports
  - *Beschreibung:*Bei Bug 6 trat ein Fehler in der Darstellung der Umsatzkategorien auf, der auf eine Inkonsistenz zwischen Backend-Response und Frontend-Datenmodell zurückzuführen war. Während das Backend die Umsätze nach Kategorien unter dem Feldnamen `revenueByCategory` zurücklieferte, erwartete das Frontend fälschlicherweise das Feld `categoryBreakdown`.

    Aufgrund dieser Abweichung konnte das Frontend die vom Backend gelieferten Daten nicht korrekt binden. Infolgedessen wurde im UI dauerhaft die Meldung „`No data available`“ angezeigt, obwohl valide Daten vorhanden waren.

    #figure(
            caption: [Abweichende Feldnamen ],
            supplement: [Listing],
            kind: raw,
            block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
            // managerApi.ts - Interface definition
            export interface RevenueReport {
                period: string;
                totalRevenue: number;
                billCount: number;
                categoryBreakdown: { category: string; revenue: number; }[];  // ❌ falscher Feldname
            }
            // reports/+page.svelte
            {#if !report.categoryBreakdown || report.categoryBreakdown.length === 0}
              <p>No data available</p>  // ← Always shows this!
            {:else}
              {#each report.categoryBreakdown as category}  //  undefined
                <!-- ... -->
              {/each}
            {/if}
            // Backend actual response:
            // {
            //   "revenueByCategory": [  ← Field name khác!
            //     { "category": "Drinks", "revenue": 125000 }
            //   ]
            // }

            //Lösung:
              ```
            ],
          )

    #figure(
            caption: [ Abweichende Feldnamen (Lösung) ],
            supplement: [Listing],
            kind: raw,
            block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
            // managerApi.ts - Aligned with backend
            export interface RevenueReport {
                period: string;
                totalRevenue: number;
                billCount: number;
                revenueByCategory: { category: string; revenue: number; itemCount: number; }[];  // richtiger Feldname
                revenueByPaymentMethod: { paymentMethod: string; amount: number; transactionCount: number; }[];  
            }
            // reports/+page.svelte
            {#if !report.revenueByCategory || report.revenueByCategory.length === 0}  // richtiger Einsatz
              <p>No data available</p>
            {:else}
              {#each report.revenueByCategory as category}  // ✅ funktioniert!
                <div>{category.category}: €{category.revenue.toLocaleString()}</div>
              {/each}
            {/if}
              ```
            ],
          )

  - *Debug-Aufwand:* ca. 0,75 Stunden

- *Bug 6* (UI / File Integrity): Beschädigte Dashboard-Seite
  - *Feature:* Manager Dashboard
  - *Beschreibung:* Bei Bug 6 trat ein kritischer Darstellungs- und Build-Fehler auf, der auf eine beschädigte Svelte-Komponente der Dashboard-Seite zurückzuführen war. Während des Bearbeitungsprozesses wurde die Datei inkonsistent verändert, wodurch mehrere strukturelle Probleme entstanden.

    Konkret enthielt die Komponente doppelte `<script>`-Blöcke, eine fehlerhafte HTML-Struktur sowie nicht zueinander passende öffnende und schließende Tags. Diese Inkonsistenzen führten dazu, dass der Svelte-Compiler die Datei nicht mehr korrekt verarbeiten konnte.

    #figure(
            caption: [ Abweichende Feldnamen (Lösung) ],
            supplement: [Listing],
            kind: raw,
            block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
                <script lang="ts">
                  import { onMount } from 'svelte';
                  // ... some code ...
                </script>

                <div class="dashboard">
                  <!-- Some content -->

                <!-- Unerwartet doppelter Script-Block -->
                <script lang="ts">
                  import { onMount } from 'svelte';
                </script>
                <!-- Fehlende bzw. inkonsistente Tags -->
                </div> <!-- zusätzliches Tag -->
                  <div>  <!-- zusätzliches öffnendes Tag -->
                <!-- Compiler-Fehler: schließendes </div> ohne entsprechendes öffnendes Element -->
              //Lösung: die zusätzliches Tags entfernen.
              ```
            ],
          )
  - *Debug-Aufwand:* ca. 0,15 Stunden (Fehler finden und fixen)

- *Bug 7* (Syntax / Build Error): Tippfehler im Variablennamen
  - *Feature:* Revenue Reports
  - *Beschreibung:* Bei Bug 7 trat ein Kompilierungsfehler auf, der durch einen syntaktischen Tippfehler im Variablennamen verursacht wurde. Konkret enthielt der Variablenbezeichner ein Leerzeichen, was in JavaScript nicht zulässig ist.

    Infolgedessen konnte der Svelte-Compiler die Komponente nicht verarbeiten und brach mit einem Syntaxfehler ab.
    #figure(
            caption: [ Abweichende Feldnamen (Lösung) ],
            supplement: [Listing],
            kind: raw,
            block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
                // reports/+page.svelte
                let is Loading = true;  //  Leerzeichen im Variablennamen

                {#if is Loading}       //  Syntax-/Compile-Fehler
                  <p>Loading...</p>
                {/if}
              //Lösung: Variablenamen anpassen
              ```
            ],
          )
  - *Debug-Aufwand:* ca. 0,15 Stunden (Fehler finden und fixen)

- *Bug 8* (Runtime / Null Safety): Null-Referenzfehler auf der Reports-Seite
  - *Feature:* Revenue Reports
  - *Beschreibung:* Bei Bug 9 trat ein Laufzeitfehler auf, der durch den Zugriff auf verschachtelte Eigenschaften eines Objekts verursacht wurde, obwohl das übergeordnete Objekt noch den Wert `null` hatte. Während des initialen Ladezustands war das Objekt `report` noch nicht initialisiert, wurde jedoch bereits in reaktiven Statements sowie im Template verwendet.

Dies führte zu einem klassischen `Null`-Referenzfehler (`Cannot read properties of null`) und verhinderte die korrekte Darstellung der Reports-Seite.

    #figure(
            caption: [ Null-Referenzfehler ],
            supplement: [Listing],
            kind: raw,
            block(fill: luma(240), inset: 8pt, radius: 4pt)[
              ```ts
                let report: RevenueReport | null = null;

                //  Reaktives Statement ohne Null-Prüfung
                $: maxCategoryRevenue = Math.max(
                    ...report.revenueByCategory.map(c => c.revenue)
                );

                //  Template greift auf null zu
                {#if report.revenueByCategory.length === 0}
                  <p>No data</p>
                {/if}

                // Runtime Error:
                // Cannot read properties of null (reading 'revenueByCategory')

                //Lösung:
                // Reaktives Statement mit Null-Sicherheit
                $: maxCategoryRevenue = report?.categoryBreakdown
                    ? Math.max(...report.categoryBreakdown.map(c => c.revenue))
                    : 1; // Sicherer Default-Wert
              //  Null checks in template
              {#if !report?.categoryBreakdown || report.categoryBreakdown.length === 0}
                <p>No data available</p>
                
              <!-- Weitere abgesicherte Zugriffe -->
              <p>{report?.categoryBreakdown?.length || 0}</p>
              <p>{report?.categoryBreakdown?.reduce((sum, c) => sum + c.itemCount, 0) || 0}</p>
                
              ```
            ],
          )
  - *Debug-Aufwand:* ca. 0,2 Stunden

=== Zwischenfazit: Fehleranalyse und Debug-Aufwand
Die systematische Analyse der aufgetretenen Fehler zeigt charakteristische Muster zwischen beiden Workflows.
+ #heading("Fehlerverteilung nach Kategorien:", level: 4, numbering: none)
  Die 26 identifizierten Bugs verteilen sich auf sieben Hauptkategorien:
  - *Data & Persistence* (8 Bugs, 38%): LazyInitializationException, fehlende `@Transactional-Annotationen` und Fetch-Strategien. Die KI generiert syntaktisch korrekten ORM-Code, übersieht jedoch Transaktionsgrenzen und Persistenz-Lifecycle.
  - *Functional Logic* (5 Bugs, 23%): Fehlende Null-Checks und Edge-Case-Validierungen. Die KI implementiert den "Happy Path" zuverlässig, vernachlässigt jedoch systematisch Randfälle.
  - * API Contract & Type Safety* (4 Bugs, 19%): Typinkonsistenzen und abweichende Feldnamen zwischen Frontend und Backend zeigen, dass die KI keinen konsistenten Vertrag über beide Schichten etabliert.
  - *Configuration & Integration* (3 Bugs, 14%): Duplicate Endpoints und inkonsistente Routing-Konfigurationen durch mangelndes Kontextwissen über die bestehende Projektstruktur.
  - *UI & Observability* (2 Bugs, 10%): Fehlende Diagramm-Achsen und Audit-Informationen – nicht-funktionale Anforderungen, die von der KI häufig übersehen werden.
  - *Security & Authorization* (1 Bug, 5% – jedoch kritisch): Vollständig fehlende serverseitige Autorisierung auf allen Endpunkten. Behebung erforderte 4–7 Stunden.
  - *Critical Incidents* (1 Bug, 5%): Git-Restore-Vorfall mit 3 Stunden Wiederherstellungsaufwand.
  #heading("Workflow-Vergleich:", level: 4, numbering: none)
  #figure(
    caption: [Bug-Aufwand nach Workflow],
    kind: table,
    table(
      columns: (2fr, 1fr, 1fr, 1.2fr),
      inset: 8pt,
      align: horizon,
      table.header([*Workflow*], [*Bugs (Backend)*], [*Bugs (Frontend)*], [*Debug-Aufwand*]),
      [Workflow 1 (Mensch → KI)], [5], [~0], [~0,6 h],
      [Workflow 2 (KI → Mensch)], [8], [8], [~14,5 h],
    ),
  )
  Die Daten zeigen ein klares Muster: Workflow 1 produzierte deutlich weniger Fehler und erforderte minimalen Debug-Aufwand, da die KI auf einer funktional korrekten Basis arbeitete. Workflow 2 war zwar schneller (6 Stunden für ~4.450 LOC), erforderte jedoch mehr als das Doppelte der Zeit für Debugging (14,5 Stunden). Besonders problematisch waren systemübergreifende Fehler (Contracts, Transaktionsgrenzen, Security), die erst zur Laufzeit sichtbar wurden.
+ #heading("Zentrale Erkenntnisse:", level: 4, numbering: none)
  - *KI-Stärken:* Schnelle Generierung von Boilerplate-Code, hohe Lesbarkeit und konsistente Code-Struktur, effektive Unterstützung bei Refactorings.
  - *KI-Schwächen:* Fehlende Berücksichtigung nicht-funktionaler Anforderungen (Security, Performance), unzureichendes Verständnis für Transaktionsgrenzen und ORM-Interna, keine proaktive Edge-Case-Validierung, mangelndes Kontextwissen über bestehende Projektstrukturen.
  // - *Implikation:* Ein *hybrider Ansatz* ist optimal. Die KI eignet sich hervorragend zur Beschleunigung repetitiver Aufgaben, erfordert jedoch intensive menschliche Kontrolle bei initialer Code-Generierung. Kritische Aspekte wie Security und Systemintegration sollten stets von erfahrenen Entwickler*innen validiert werden.


== Zwischenfazit (Kapitel 4)
Dieses Kapitel stellte die praktische Anwendung zweier gegensätzlicher Entwicklungsansätze dar. Die empirischen Daten zeigen einen deutlichen Zielkonflikt zwischen Geschwindigkeit und Stabilität.
#figure(
  caption: [Zusammenfassender Vergleich der Workflows],
  kind: table,
  table(
    columns: (2fr, 1.2fr, 1.2fr, 1fr),
    inset: 8pt,
    align: horizon,
    table.header([*Metrik*], [*Workflow 1*], [*Workflow 2*], [*Tendenz*]),
    [Entwicklungszeit], [~3 Tage], [~20,5 h], [WF2 schneller],
    [Fehleranzahl], [5], [24], [WF1 stabiler],
    [Codequalität (Ø)], [4,2/5], [3,2/5], [WF1 hochwertiger],
    [Debug-Anteil], [< 2%], [> 70%], [WF1 effizienter],
  ),
)
Während Workflow 2 eine massive Beschleunigung der initialen Implementierung ermöglicht (-66% Gesamtzeit), erkauft man sich diesen Vorteil mit einer vervielfachten Fehlerrate und signifikantem Debugging-Aufwand. Workflow 1 hingegen liefert durchgehend höhere Qualität und Sicherheit.
*Überleitung:* Eine detaillierte vergleichende Analyse dieser Befunde, einschließlich der Untersuchung von Ursache-Wirkungs-Beziehungen und der Ableitung eines Entscheidungsrahmens für die Praxis, erfolgt im anschließenden Kapitel 5.

