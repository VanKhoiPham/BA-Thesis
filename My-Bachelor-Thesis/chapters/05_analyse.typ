= Vergleichende Analyse

== Zeitlicher Aufwand
// Lập bảng so sánh ước lượng:
// Setup & Config: 4h vs 0.5h (8x)
// CRUD APIs (Manager): 6h vs 0.7h (8.5x)
// Logic Promotion: 3h vs 2h (1.5x)
Die folgende Tabelle vergleicht den zeitlichen Aufwand (geschätzt):

#figure(
  table(
    columns: (auto, auto, auto, auto),
    table.header([Tác vụ], [Thủ công (h)], [KI + Mensch (h)], [Beschleunigung]),
    [Setup & Config], [4], [0.5], [8x],
    [CRUD APIs (Manager)], [6], [0.7], [8.5x],
    [Logic Promotion], [3], [2], [1.5x],
  ),
  caption: [Zeitlicher Aufwand im Vergleich],
  kind: table,
)

// Nhận xét: AI tăng tốc cực đại ở các tác vụ lặp lại, nhưng giảm hiệu quả ở logic nghiệp vụ phức tạp.
*Fazit:* Die KI bietet maximale Beschleunigung bei repetitiven Aufgaben, während der Vorteil bei komplexer Geschäftslogik geringer ausfällt.

== Codequalität und Wartbarkeit
// Cohesion: Code AI (Version 2) có độ kết dính cao hơn (gom theo Feature).
- *Kohäsion*: Der von der KI refactorierte Code (Version 2) weist durch die Feature-basierte Struktur eine höhere Kohäsion auf.
// Testability: Code AI dùng Dependency Injection (@Inject) giúp Unit Test dễ dàng hơn so với Static method cũ.
- *Testbarkeit*: Durch konsequente Nutzung von Dependency Injection (`@Inject`) ist der KI-Code besser testbar als statische Methodenansätze.

== Fehleranfälligkeit
// AI hay mắc lỗi "ngớ ngẩn" (biến có dấu cách is Loading) hoặc lỗi ngữ cảnh.
- *KI-Fehler*: Häufig syntaktische "Flüchtigkeitsfehler" (z. B. Leerzeichen in Variablennamen wie `is Loading`) oder Kontextfehler.
// Con người hay mắc lỗi cấu hình và logic flow.
- *Menschliche Fehler*: Neigen eher zu Konfigurationsfehlern und Problemen im logischen Ablauf.
