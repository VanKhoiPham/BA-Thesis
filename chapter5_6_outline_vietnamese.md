# Outline Chương 5 & 6 (Tiếng Việt - Để Review)

## 📊 CHƯƠNG 5: PHÂN TÍCH SO SÁNH

### Mục tiêu: So sánh hai workflows qua định lượng và định tính, nhận diện patterns, phân tích nguyên nhân

### 5.1 Định lượng so sánh

**Bảng 1: Tổng hợp thời gian**
```
Metric              | WF1         | WF2        | Diff
LOC Total           | 2,648       | 4,950      | +87%
Gen/Impl Time       | ~48h        | ~6h        | -88%
Debug Time          | ~2.5h       | ~10.5h     | +320%
Total Time          | ~50.5h      | ~16.5h     | -67%
Bugs                | 5           | 21         | +320%
```

**Nhận xét:** WF2 nhanh hơn 67% nhưng có 3.2× bugs và debug time cao gấp 3×

**Bảng 2: Bug Distribution**
- Data & Persistence: 38% (biggest category)
- WF1: Bugs tập trung ở 2 categories
- WF2: Bugs phân tán MỌI categories

**Bảng 3: Quality Scores**
- WF1 Overall: 4.4/5
- WF2 Overall: 3.3/5
- WF2 chỉ thắng ở Readability

### 5.2 Phân tích định tính

**5.2.1 Bug Pattern Catalog (7 loại)**

Pattern 1: Data & Persistence (8 bugs)
- LazyInitializationException, Missing @Transactional
- WHY: AI không hiểu Hibernate Session lifecycle

Pattern 2: API Contract (4 bugs)
- Field mismatches giữa Frontend/Backend
- WHY: AI gen riêng rẽ, thiếu contract

Pattern 3: Edge Cases (5 bugs)
- Null checks, validation thiếu
- WHY: AI focus "happy path"

Pattern 4: Security (1 bug - CRITICAL)
- Missing @RolesAllowed on ALL endpoints
- WHY: Security không explicit trong prompt

[3 patterns nữa...]

** 5.2.2 Root Cause Analysis**

Technical Causes:
1. Context Window Limit → không nhìn thấy full codebase
2. No Runtime Semantics → không hiểu transaction timing
3. Probabilistic Generation → random syntax errors
4. Training Data Bias → replicate bad patterns

System Causes:
1. No Architectural Context
2. No Testing Feedback Loop

**5.2.3 Workflow Comparison**

WF1 Strengths: Quality, security, edge cases
WF1 Weaknesses: Slow

WF2 Strengths: Fast, readable, boilerplate
WF2 Weaknesses: Bugs, security gaps, performance

### 5.3 Solution Strategies

1. Contract-First Prompting
2. Constraint-Based Prompting
3. Iterative Refinement
4. Security Checklist
5. Hybrid Workflow (best of both)

### 5.4 Summary

Decision Framework: Khi nào dùng WF1 vs WF2
- High complexity/criticality → WF1
- Prototyping/low criticality → WF2

---

## 💬 CHƯƠNG 6: THẢO LUẬN

### 6.1 Research Context

So sánh với existing studies:
- GitHub Copilot Study: 55% faster (WF2: 67% ✅)
- AI Quality Study: 2-3× bugs (WF2: 2.2× ✅)

Contribution của thesis:
- First systematic workflow comparison
- 7 bug pattern categories identified
- Hybrid approach proposed

### 6.2 Methodological Limitations

⚠️ CRITICAL HONESTY SECTION:

1. Sample Size: n=21 (nhỏ, không đủ cho statistical inference)
2. Single Project: Restaurant app (không generalize được)
3. Subjective Quality Scores: Chỉ 1 người chấm
4. AI Tool Specific: GPT-4/Claude only
5. Time-Bound: AI improve nhanh, findings có thể outdated
6. Developer Skill: Intermediate level (không represent all levels)

Threats to Validity:
- Internal: Selection bias, measurement bias
- External: Low generalizability
- Construct: Quality measurement có valid?

### 6.3 Practical Implications

**For Developers:**
- Role shift: Code Writer → Architect + Reviewer
- New skills: Prompt engineering, rapid review, security awareness

**For Teams:**
- Process changes: Extra review cho AI code
- Documentation: Track AI prompts và iterations

**For Education:**
- Curriculum shift: Thêm prompt engineering, advanced debugging
- Still critical: Fundamentals, algorithms, system design
- Challenge: Students dùng AI làm homework

### 6.4 Future Research

Research Gaps:
1. Long-term maintenance của AI code?
2. Team dynamics impact?
3. Cross-domain validation?
4. AI tool comparison?

Proposed Studies:
1. Multi-project replication (n≥100)
2. Controlled experiment (2 groups)
3. AI evolution tracking (every 6 months)

Open Questions:
- Optimal hybrid ratio?
- Developer skill impact?
- Domain boundaries?
- Economic ROI?
- Ethical considerations?

---

Bạn review outline này, có OK không? Sau đó tôi viết full content tiếng Đức.
