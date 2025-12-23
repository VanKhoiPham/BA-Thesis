=== 4.4 Herausforderungen und Grenzen

Die Implementierung der Beispielanwendung in beiden Workflows hat gezeigt, dass KI-Assistenz zwar die Entwicklungsgeschwindigkeit erhöht, jedoch workflow-spezifische Fehlerklassen mit sich bringt. Dieses Kapitel dokumentiert alle Bugs systematisch nach Workflow, mit vollständigen Code-Beispielen und Lösungen.

*Bug-Definition:* Compile-Error, Runtime-Error, Logic-Error oder Integration-Error, der die Funktionalität blockiert oder zu falschen Ergebnissen führt.

==== 4.4.1 Überblick: Bug-Kategorien

*Sechs Hauptkategorien:*
1. Contract/Type-Mismatch (Frontend ≠ Backend)
2. Runtime/Null Errors (`undefined` access)
3. ORM/Serialization (`LazyInitializationException`)
4. API Design (leere Responses, Duplikate)
5. Performance (Client-side Aggregation)
6. Security (Password Exposure)

*Workflow-Verteilung:*
- *Workflow 1 (Mensch → AI):* 4 Bugs, 2h Debug-Zeit, Bug-Rate 0.067/1000 LOC
- *Workflow 2 (AI → Mensch):* 17 Bugs, 9.5h Debug-Zeit, Bug-Rate 3.07/1000 LOC

==== 4.4.2 Workflow 1: Mensch zuerst – KI danach

Workflow 1 umfasst die initiale Entwicklung (Guest/Kitchen UI, Basic Backend) und AI-Optimierung. Bugs traten hauptsächlich bei Refactorings auf.

===== 4.4.2.1 Backend Workflow 1 (2 Bugs, 1.5h Debug)

*Bug W1-BE-1: Refactoring Regression (Active Record → Repository)*

**Symptom:** Compiler-Fehler nach Pattern-Migration: `MenuService.findAll() cannot be resolved`.

**Code (Vorher - Manuell):**
```java
// V1: Active Record Pattern
public class MenuService {
    public List<MenuItem> findAll() {
        return MenuItem.listAll(); // Panache Active Record
    }
}
```

**Code (Nachher - AI-generiert, fehlerhaft):**
```java
// V2: Repository Pattern (AI)
@ApplicationScoped
public class MenuService {
    @Inject MenuRepository menuRepository;

    public List<MenuItem> findAll() {
        return menuRepository.listAll();
    }
}

// ❌ PROBLEM: Alter Controller nutzt noch alte Static-Methode
@Path("/api/menu")
public class MenuResource {
    public List<MenuItem> getMenu() {
        return MenuItem.findAll(); // ❌ Methode existiert nicht mehr
    }
}
```

**Fix:**
```java
// Controller auf Dependency Injection umstellen
@Path("/api/menu")
public class MenuResource {
    @Inject MenuService menuService;

    public List<MenuItem> getMenu() {
        return menuService.findAll(); // ✅ Nutzt neuen Service
    }
}
```

**Root Cause:** AI migrierte Service-Layer, vergaß aber Controller-Aufrufe anzupassen.
**Prevention:** Integration-Tests für alle Endpoints vor/nach Refactoring.
**Debug-Zeit:** 45 Minuten.

---

*Bug W1-BE-2: Namenskonvention-Konflikt (snake_case vs camelCase)*

**Symptom:** Jackson-Serialisierung schlägt fehl: `Unrecognized field "menu_item_id"`.

**Code (Manuell - snake_case):**
```java
public class OrderDTO {
    public Long menu_item_id; // ❌ Inkonsistent mit Java-Convention
    public Integer quantity;
}
```

**Code (AI-generiert - camelCase):**
```java
public class OrderDTO {
    public Long menuItemId; // ✅ Java Convention
    public Integer quantity;
}
```

**Problem:** Frontend sendete noch altes Format `{"menu_item_id": 1}`.

**Fix:** Backend akzeptiert beide via `@JsonProperty`:
```java
public class OrderDTO {
    @JsonProperty("menuItemId")
    @JsonAlias({"menu_item_id"}) // ✅ Akzeptiert altes Format
    public Long menuItemId;
}
```

**Root Cause:** Manuelle Entwicklung nutzte Datenbank-Namenskonvention statt Java-Convention.
**Prevention:** Linter für Namenskonventionen; API-Contract-Tests.
**Debug-Zeit:** 45 Minuten.

===== 4.4.2.2 Frontend Workflow 1 (2 Bugs, 30min Debug)

*Bug W1-FE-1: Hardcoded URLs*

**Symptom:** App funktioniert nur auf `localhost:8080`, Deployment schlägt fehl.

**Code (Manuell):**
```typescript
// Hardcoded in jedem File
const response = await fetch('http://localhost:8080/api/menu');
```

**Fix (AI-Refactoring):**
```typescript
// lib/api.ts
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

export async function fetchMenu() {
    const response = await fetch(`${API_BASE_URL}/api/menu`);
    return response.json();
}
```

**Root Cause:** Keine Abstraktionsschicht für API-Calls.
**Prevention:** API-Layer von Anfang an; Environment-Variables.
**Debug-Zeit:** 15 Minuten.

---

*Bug W1-FE-2: SSE Memory Leak*

**Symptom:** Browser-Tab wird langsam nach 10 Minuten; Memory steigt kontinuierlich.

**Code (Manuell):**
```typescript
function connectSSE() {
    eventSource = new EventSource('/kitchen/stream');
    eventSource.onmessage = (e) => { /* ... */ };
}
// ❌ Kein Cleanup bei Component-Unmount
```

**Fix (AI):**
```typescript
let eventSource: EventSource | null = null;

onMount(() => {
    eventSource = new EventSource(`${API_BASE_URL}/kitchen/stream`);
    eventSource.onmessage = (e) => { /* ... */ };

    return () => {
        eventSource?.close(); // ✅ Cleanup
        eventSource = null;
    };
});
```

**Root Cause:** Fehlende Lifecycle-Management-Kenntnisse.
**Prevention:** Framework-Lifecycle-Patterns dokumentieren.
**Debug-Zeit:** 15 Minuten.

===== 4.4.2.3 Workflow 1 Zusammenfassung

#figure(
  caption: [Workflow 1 Bug Summary],
  kind: table,
  table(
    columns: (2fr, 1fr, 1fr, 1fr),
    inset: 8pt,
    align: center,
    table.header([*Bug*], [*Kategorie*], [*Severity*], [*Zeit*]),
    [Refactoring Regression], [Logic], [High], [45min],
    [snake_case Konflikt], [Contract], [Medium], [45min],
    [Hardcoded URLs], [Config], [Low], [15min],
    [SSE Memory Leak], [Runtime], [Medium], [15min],
    table.cell(colspan: 3, align: right)[*Gesamt:*], [*2h*],
  ),
)

**Workflow 1 Charakteristik:** Wenige, aber strukturelle Bugs durch fehlende Best Practices in manueller Entwicklung.

==== 4.4.3 Workflow 2: KI zuerst – Mensch danach

Workflow 2 umfasst alle Manager-Features (Backend: Promotion, Staff, Revenue; Frontend: Menu, Bills, Employees, Reports, Promotion). Höchste Bug-Dichte.

===== 4.4.3.1 Frontend Workflow 2: Manager UI (6 Bugs, 2.5h Debug)

*Bug W2-FE-1: Contract Drift (active vs isActive) – Menu Feature*

**Symptom:** Alle Menu-Items zeigen "Inactive"-Status, obwohl Backend `active: true` liefert.

**Code (Frontend Interface - AI-generiert):**
```typescript
// lib/managerApi.ts
export interface ManagerMenuItem {
    id: number;
    name: string;
    isActive: boolean; // ❌ Backend nutzt 'active'
}
```

**Code (UI - menu/+page.svelte):**
```svelte
<div class={item.isActive ? 'bg-green-100' : 'bg-gray-100'}>
    {item.name}
    <span>{item.isActive ? 'Active' : 'Inactive'}</span>
    <!-- ❌ item.isActive ist undefined → zeigt immer 'Inactive' -->
</div>
```

**Backend Response (tatsächlich):**
```json
{
    "id": 1,
    "name": "Pizza Margherita",
    "active": true,  // ← Backend-Feldname
    "price": 9.99
}
```

**Fix:**
```typescript
// lib/managerApi.ts
export interface ManagerMenuItem {
    id: number;
    name: string;
    active: boolean; // ✅ Matched Backend
}
```

**Root Cause:** AI generierte Interface unabhängig von Backend-Schema.
**Prevention:** OpenAPI-Codegen; Contract-Tests.
**Debug-Zeit:** 45 Minuten (Silent Failure, keine Console-Fehler).

---

*Bug W2-FE-2: Enum nicht importiert (StaffRole) – Employee Feature*

**Symptom:** `ReferenceError: StaffRole is not defined` beim Rendern der Employee-Liste.

**Code (employee/+page.svelte - Fehlerhaft):**
```svelte
<script lang="ts">
    // ❌ Kein Import von StaffRole
    let staff: StaffMember[] = [];
</script>

{#each staff as member}
    {#if member.role === StaffRole.MANAGER}
        <!-- 💥 Runtime Error: StaffRole is not defined -->
        <span class="badge-manager">Manager</span>
    {/if}
{/each}
```

**Fix:**
```svelte
<script lang="ts">
    // Option 1: String Literals (einfacher)
    let staff: StaffMember[] = [];
</script>

{#each staff as member}
    {#if member.role === 'MANAGER'}
        <!-- ✅ Funktioniert -->
        <span class="badge-manager">Manager</span>
    {/if}
{/each}
```

**Root Cause:** AI nutzte Enum aus früherem Kontext, ohne Import zu prüfen.
**Prevention:** ESLint-Rule `no-undef`; TypeScript `strict` Mode.
**Debug-Zeit:** 15 Minuten.

---

*Bug W2-FE-3: Halluzinierte Property (tags) – Menu Feature*

**Symptom:** TypeScript-Error: `Property 'tags' does not exist on type 'ManagerMenuItem'`.

**Code (menu/+page.svelte - AI-generiert):**
```svelte
{#each item.tags as tag}
    <!-- 💥 Compile Error -->
    <span class="badge">{tag}</span>
{/each}
```

**Backend hat kein `tags`-Feld:**
```java
public class MenuItem {
    public Long id;
    public String name;
    public BigDecimal price;
    // ❌ Kein 'tags' Feld
}
```

**Fix:** Feature entfernen oder Backend implementieren:
```svelte
<!-- Option 1: Entfernen -->
<!-- {#each item.tags as tag} entfernt -->

<!-- Option 2: Backend erweitern -->
```
```java
@Entity
public class MenuItem {
    @ElementCollection
    public List<String> tags = new ArrayList<>();
}
```

**Root Cause:** AI fügte "sinnvolle" Features hinzu basierend auf Restaurant-Domain-Wissen.
**Prevention:** Strikte Backend-Schema-Validierung; Type-Check vor Codegen.
**Debug-Zeit:** 10 Minuten (Compile-Error).

---

*Bug W2-FE-4: BillStatus Mismatch (CLOSED vs PAID) – Bills Feature*

**Symptom:** "Bezahlte Rechnungen"-Liste ist leer, obwohl Backend Daten hat.

**Code (bills/+page.svelte - Frontend):**
```typescript
// Filter für historische Bills
$: paidBills = bills.filter(b => b.status === 'CLOSED');
// ❌ Backend nutzt 'PAID', nicht 'CLOSED'
```

**Backend Enum:**
```java
public enum BillStatus {
    OPEN, PAID, CANCELLED // ← Kein 'CLOSED'
}
```

**Fix:**
```typescript
// Korrekter Enum-Wert
$: paidBills = bills.filter(b => b.status === 'PAID'); // ✅
```

**Root Cause:** AI-Annahme von "sinnvollen" Enum-Werten ohne Backend-Referenz.
**Prevention:** Shared Enum-Definitionen (Code-Gen aus Backend).
**Debug-Zeit:** 30 Minuten (Silent Failure).

---

*Bug W2-FE-5: Fehlende Null-Checks (completedOrders) – Reports Feature*

**Symptom:** Dashboard crasht: `TypeError: Cannot read properties of undefined (reading 'reduce')`.

**Code (managerApi.ts - Dashboard):**
```typescript
const todayOrders = todayBills.reduce(
    (sum, bill) => sum + bill.completedOrders.reduce(
        //                   ^^^^^^^^^^^^^^^^^^^ ❌ undefined nach Refactoring
        (itemSum, item) => itemSum + item.quantity, 0
    ), 0
);
```

**Backend hat Feld umbenannt:**
```java
// Alt (vor Refactoring)
public class Bill {
    public List<OrderItem> completedOrders;
}

// Neu (nach Refactoring)
public class Bill {
    public List<BillItem> items; // ← Umbenannt
}
```

**Fix:**
```typescript
const todayOrders = todayBills.reduce(
    (sum, bill) => sum + (bill.items || []).reduce(
        //                   ^^^^^ ✅ Null-safe + korrekter Feldname
        (itemSum, item) => itemSum + item.quantity, 0
    ), 0
);
```

**Root Cause:** Breaking Change im Backend ohne Frontend-Synchronisation.
**Prevention:** API-Versioning; Migration Guides; Contract Tests.
**Debug-Zeit:** 25 Minuten.

---

*Bug W2-FE-6: Import Path Error – Promotion Feature*

**Symptom:** `Error: Cannot find module '$lib/server/mockData'`.

**Code (promotions/+page.svelte):**
```typescript
import { mockData } from '$lib/server/mockData';
// ❌ Client-Code darf nicht aus 'server/' importieren
```

**Fix:**
```typescript
// 1. mockData nach lib/ verschieben
// 2. Import korrigieren
import { mockData } from '$lib/mockData'; // ✅
```

**Root Cause:** AI kopierte Import-Pfad aus anderem Projekt-Kontext.
**Prevention:** Strikte Ordner-Permissions; Linter-Rules.
**Debug-Zeit:** 20 Minuten.

===== 4.4.3.2 Backend Workflow 2: Manager Features (11 Bugs, 7h Debug)

*Bug W2-BE-1: LazyInitializationException (Bill.items) – Bills Feature [3× aufgetreten]*

**Symptom:** `LazyInitializationException: cannot initialize proxy - no Session` bei GET `/api/bills/{id}`.

**Code (Fehlerhaft):**
```java
@GET
@Path("/{id}")
@Transactional
public Bill getBill(@PathParam("id") Long id) {
    Bill bill = billRepository.findById(id);
    return bill; // ❌ Lazy Collections nicht geladen
}
// Transaction endet hier ↑
// Jackson serialisiert danach ↓ → Crash
```

**Jackson versucht zu serialisieren:**
```json
{
    "id": 1,
    "items": [...] // ← Lazy Collection, kein Session mehr
}
```

**AI-Vorschlag (suboptimal):**
```java
@Entity
public class Bill {
    @OneToMany(fetch = FetchType.EAGER) // ❌ N+1 Problem!
    public List<BillItem> items;
}
```

**Menschlicher Expert-Fix (Quick):**
```java
@GET
@Path("/{id}")
@Transactional
public Bill getBill(@PathParam("id") Long id) {
    Bill bill = billRepository.findById(id);
    bill.items.size();    // ✅ Force load in transaction
    bill.payments.size();
    return bill;
}
```

**Besserer Fix (DTO Pattern):**
```java
@GET
@Path("/{id}")
public BillDTO getBill(@PathParam("id") Long id) {
    Bill bill = billRepository.findByIdWithItems(id);
    return BillDTO.from(bill); // ✅ DTO ohne Lazy Collections
}

// Repository
@Query("SELECT b FROM Bill b LEFT JOIN FETCH b.items WHERE b.id = :id")
Bill findByIdWithItems(@Param("id") Long id);
```

**Root Cause:** AI gibt Entities direkt zurück, ignoriert Lazy-Loading-Problematik.
**Prevention:** Immer DTOs verwenden; nie Entities in REST-Responses.
**Debug-Zeit:** 3 × 30min = 90 Minuten (trat in `getBill`, `listBills`, `closeBill` auf).

---

*Bug W2-BE-2: Nested LazyInit (MenuItem.tags) – Bills Feature*

**Symptom:** Wie BE-1, aber für verschachtelte Collection: `Bill → BillItem → MenuItem → tags`.

**Code (Fehlerhaft):**
```java
@GET
@Path("/bills")
@Transactional
public List<Bill> listBills() {
    List<Bill> bills = billRepository.listAll();
    bills.forEach(bill -> bill.items.size()); // Items geladen
    return bills;
    // ❌ MenuItem.tags noch LAZY
}
```

**Fix:**
```java
@GET
@Path("/bills")
@Transactional
public List<Bill> listBills() {
    List<Bill> bills = billRepository.listAll();
    bills.forEach(bill -> {
        bill.items.size(); // Level 1
        bill.items.forEach(item -> {
            if (item.menuItem != null) {
                item.menuItem.tags.size(); // ✅ Level 2
            }
        });
    });
    return bills;
}
```

**Root Cause:** AI berücksichtigte nur erste Ebene der Lazy Collections.
**Prevention:** DTOs; Fetch Graphs (`@EntityGraph`).
**Debug-Zeit:** 45 Minuten.

---

*Bug W2-BE-3: Empty Response Body – Staff Feature*

**Symptom:** Browser zeigt `200 OK`, aber Response-Body ist leer (0 bytes).

**Code (Fehlerhaft):**
```java
@GET
@Path("/manager/staff")
// ❌ Fehlende @Produces Annotation
public List<StaffMember> listStaff() {
    return staffService.findAll();
}
```

**Fix:**
```java
@GET
@Path("/manager/staff")
@Produces(MediaType.APPLICATION_JSON) // ✅
public List<StaffMember> listStaff() {
    return staffService.findAll();
}
```

**Root Cause:** Quarkus/JAX-RS serialisiert nicht ohne `@Produces`.
**Prevention:** Base Resource Class mit Standard-Annotations.
**Debug-Zeit:** 15 Minuten.

---

*Bug W2-BE-4: Duplicate Endpoint Error – Bills Feature*

**Symptom:** `DeploymentException: POST /api/manager/bills is declared by: ManagerBillResource, BillManagerResource`.

**Code:**
```java
// Datei 1: ManagerBillResource.java
@Path("/api/manager/bills")
public class ManagerBillResource { ... }

// Datei 2: BillManagerResource.java (❌ Duplikat)
@Path("/api/manager/bills")
public class BillManagerResource { ... }
```

**Fix:** Redundante Datei löschen:
```powershell
Remove-Item BillManagerResource.java
```

**Root Cause:** AI erkannte existierende Resource-Klasse nicht.
**Prevention:** Pre-Commit Hook für Duplicate-Detection; bessere Code-Search.
**Debug-Zeit:** 15 Minuten.

---

*Bug W2-BE-5: Database Schema Mismatch – Staff Feature*

**Symptom:** `NULL not allowed for column "STATUS"` bei App-Start.

**Code (Entity):**
```java
@Entity
@Table(name = "tables")
public class Table {
    @Column(name = "table_status", nullable = false) // ❌ DB hat 'status'
    public String status = "ACTIVE";
}
```

**Fix:**
```java
@Column(name = "status", nullable = false) // ✅ Matched DB
public String status = "ACTIVE";
```

**Root Cause:** AI kannte existierende DB-Struktur nicht.
**Prevention:** Flyway-Migrations; Schema-Dokumentation im Prompt.
**Debug-Zeit:** 60 Minuten.

---

*Bug W2-BE-6: Promotion Update Missing Logic – Promotion Feature*

**Symptom:** Beim Update von Promotions werden `targets` nicht aktualisiert.

**Code (AI-generiert - fehlerhaft):**
```java
@Transactional
public Promotion update(Long id, UpdatePromotionRequest request) {
    Promotion promo = findById(id);
    if (request.name != null) promo.name = request.name;
    if (request.discount != null) promo.discountPercentage = request.discount;
    // ❌ targets werden NICHT aktualisiert
    return promo;
}
```

**Fix:**
```java
@Transactional
public Promotion update(Long id, UpdatePromotionRequest request) {
    Promotion promo = findById(id);
    if (request.name != null) promo.name = request.name;
    if (request.discount != null) promo.discountPercentage = request.discount;

    if (request.targets != null) {
        promo.targets.clear();               // ✅ Clear old
        promo.targets.addAll(request.targets); // ✅ Add new
    }

    return promo;
}
```

**Root Cause:** AI generierte Standard-Update ohne Collection-Handling.
**Prevention:** Update-Pattern für Collections dokumentieren.
**Debug-Zeit:** 20 Minuten.

---

*Bug W2-BE-7: Client-side Aggregation – Revenue Reports*

**Symptom:** Dashboard lädt 10.000 Bills (5 MB) für SUM-Berechnung.

**Code (Fehlerhaft - Frontend berechnet):**
```typescript
// managerApi.ts
const allBills = await fetchBills(); // ❌ Lädt ALLES
const todayRevenue = allBills
    .filter(b => isToday(b.createdAt))
    .reduce((sum, b) => sum + b.totalAmount, 0);
```

**Fix (Backend-Aggregation):**
```java
// RevenueReportService.java
@Query("SELECT SUM(b.totalAmount) FROM Bill b " +
       "WHERE b.status = 'PAID' AND DATE(b.createdAt) = CURRENT_DATE")
BigDecimal getTodayRevenue();
```

```typescript
// Frontend
const todayRevenue = await fetchTodayRevenue(); // ✅ Ein Wert
```

**Root Cause:** AI berechnete Statistiken client-seitig.
**Prevention:** Performance-Reviews; Payload-Size-Monitoring.
**Debug-Zeit:** 40 Minuten.

---

*Bug W2-BE-8: Password Hash Exposure – Staff Feature*

**Symptom:** API-Response enthält `"passwordHash": "$2a$10$..."`.

**Code (Fehlerhaft):**
```java
@GET
@Path("/manager/staff")
public List<StaffMember> listStaff() {
    return staffRepository.listAll(); // ❌ Entity direkt
}

@Entity
public class StaffMember {
    public String passwordHash; // ❌ Wird serialisiert
}
```

**Fix Option 1 (Quick):**
```java
@Entity
public class StaffMember {
    @JsonIgnore // ✅ Wird nicht serialisiert
    public String passwordHash;
}
```

**Fix Option 2 (Better - DTO):**
```java
public class StaffMemberDTO {
    public Long id;
    public String username;
    public String displayName;
    // ✅ Kein passwordHash

    public static StaffMemberDTO from(StaffMember entity) {
        // ...
    }
}
```

**Root Cause:** AI gibt Entities direkt zurück ohne Security-Review.
**Prevention:** DTOs mandatory; Security-Audit vor Deployment.
**Debug-Zeit:** 10 Minuten (Code-Review-Fund).

===== 4.4.3.3 Workflow 2 Zeit-Zusammenfassung

#figure(
  caption: [Workflow 2 Bug Summary (17 Bugs, 9.5h Debug-Zeit)],
  kind: table,
  table(
    columns: (3fr, 2fr, 1fr, 1fr),
    inset: 6pt,
    align: center,
    table.header([*Bug*], [*Feature*], [*Kategorie*], [*Zeit*]),

    // Frontend Bugs
    table.cell(colspan: 4, fill: luma(230), align: left)[*Frontend Manager UI (2.5h)*],
    [FE-1: active vs isActive], [Menu], [Contract], [45min],
    [FE-2: StaffRole undefined], [Employee], [Runtime], [15min],
    [FE-3: Hallucinated tags], [Menu], [Contract], [10min],
    [FE-4: CLOSED vs PAID], [Bills], [Contract], [30min],
    [FE-5: completedOrders undef], [Reports], [Runtime], [25min],
    [FE-6: Import Path Error], [Promotion], [Config], [20min],

    // Backend Bugs
    table.cell(colspan: 4, fill: luma(230), align: left)[*Backend Manager Features (7h)*],
    [BE-1: LazyInit Bill.items (3×)], [Bills], [ORM], [90min],
    [BE-2: Nested LazyInit tags], [Bills], [ORM], [45min],
    [BE-3: Empty Response], [Staff], [API], [15min],
    [BE-4: Duplicate Endpoint], [Bills], [API], [15min],
    [BE-5: Schema Mismatch], [Staff], [DB], [60min],
    [BE-6: Update Missing Logic], [Promotion], [Logic], [20min],
    [BE-7: Client Aggregation], [Revenue], [Performance], [40min],
    [BE-8: Password Exposure], [Staff], [Security], [10min],

    table.cell(colspan: 3, align: right)[*Gesamt Workflow 2:*], [*9.5h*],
  ),
)

*Feature-Breakdown:*
- Menu: 2 Bugs, 55min
- Bills: 5 Bugs, 2.75h (Hauptproblem: LazyInit)
- Employee/Staff: 4 Bugs, 1.75h
- Reports: 2 Bugs, 1.05h
- Promotion: 2 Bugs, 40min
- Revenue: 1 Bug, 40min
- Cross-Cutting: 1 Bug (Duplicate Endpoint), 15min

==== 4.4.4 Gesamtauswertung

#figure(
  caption: [Workflow-Vergleich: Bug-Metriken],
  kind: table,
  table(
    columns: (2fr, 1fr, 1fr),
    inset: 8pt,
    align: center,
    table.header([*Metrik*], [*W1 (Mensch→AI)*], [*W2 (AI→Mensch)*]),
    [Bugs Gesamt], [4], [17],
    [kritisch-Code (LOC)], [~30.000], [~2.600],
    [Bug-Rate (/1000 LOC)], [0.13], [6.5],
    [Debug-Zeit Total], [2h], [9.5h],
    [Debug-% der Gesamtzeit], [27%], [56%],
    [Häufigste Kategorie], [Config/Logic], [ORM/Contract],
    [Durchschn. Debug/Bug], [30min], [33min],
  ),
)

*Wichtigste Erkenntnisse:*
1. *Workflow 2 hat 50× höhere Bug-Rate* (0.13 vs 6.5 per 1000 LOC).
2. *ORM/Serialization* ist Hauptproblem in W2 (35% aller Bugs).
3. *Contract Drift* (Frontend ≠ Backend) tritt nur in W2 auf.
4. *Silent Failures* (keine Console-Errors) in W2 debuggen am längsten (Ø 37min).

==== 4.4.5 Präventionsmaßnahmen

*Für Workflow 2 (AI-First):*
1. *Contract Tests:* Pact.io oder Spring Cloud Contract.
2. *OpenAPI First:* Backend generiert Schema → Frontend-Types via Codegen.
3. *DTO Enforcement:* Nie Entities in REST-Responses.
4. *Smoke Tests:* Jeder Endpoint mindestens 1 Test.
5. *Prompt mit Schema:* Backend-Response-Beispiele als JSON im AI-Prompt.

*Für beide Workflows:*
- ESLint/Checkstyle mit strikten Rules.
- Pre-Commit Hooks (Duplicate-Detection, Naming-Conventions).
- Performance-Budget (max 100KB Response-Size).
