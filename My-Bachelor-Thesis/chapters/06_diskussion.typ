= Diskussion der Ergebnisse

== Ursachenanalyse von KI-Fehlern
// Context Window Limit: AI không nhớ hết toàn bộ project (gây lỗi categoryBreakdown).
- *Context Window Limit*: Die Begrenzung des Kontextfensters führt dazu, dass die KI nicht das gesamte Projekt überblicken kann, was zu Fehlern wie im Fall `categoryBreakdown` führt.
// Probabilistic Nature: Bản chất sinh từ ngẫu nhiên gây lỗi cú pháp (is Loading).
- *Probabilistische Natur*: Die statistische Wahrscheinlichkeit bei der Textgenerierung kann zu syntaktischen Fehlern führen (z. B. `is Loading`).

== Entwickelte Lösungsstrategien
// Strategy 1: Contract-First Prompting: Cung cấp JSON Response mẫu trước khi yêu cầu AI viết Frontend để tránh ảo giác tên biến.
1. *Contract-First Prompting*: Bereitstellung von JSON-Response-Mustern, bevor die KI Frontend-Code generiert, um Halluzinationen bei Variablennamen zu vermeiden.
// Strategy 2: Constraint-Based Prompting: Ra lệnh cấm dùng Eager Loading ngay từ đầu để tránh lỗi hiệu năng DB.
2. *Constraint-Based Prompting*: Explizite Anweisungen (Constraints) von Beginn an, z. B. das Verbot von "Eager Loading", um Performance-Probleme zu verhindern.

== Rolle des Entwicklers
// Chuyển dịch từ "Code Writer" sang "System Architect" và "Code Reviewer".
Die Rolle des Entwicklers wandelt sich vom reinen "Code Writer" hin zum "System Architect" und "Code Reviewer", der die KI-Ergebnisse prüft und integriert.
