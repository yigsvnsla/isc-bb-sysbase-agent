# ISC COBOL Banking System — Agent Guide

## Mission

Build complete legacy banking system in Micro Focus COBOL. Serves as training dataset for AI agent that migrates COBOL → Angular. No Angular code. No modern COBOL syntax.

## Timeframe & Aesthetic

Code must look like real system developed 1995–2010 by multiple teams. Inconsistent styles, varying skill levels, organic cruft expected. Not a cleanroom project.

## Tech Stack

- **COBOL**: Micro Focus COBOL (not GnuCOBOL, not IBM Enterprise)
- **Screen I/O**: `SCREEN SECTION`, `ACCEPT`/`DISPLAY`, 80×24 terminal, PF-key navigation
- **Data**: Indexed files (VSAM equivalent), `COPYBOOKS`, embedded SQL (simulated where needed)
- **Inter-program**: `CALL` between independent programs. No nested programs unless legacy pattern demands it.

## Required COBOL Features

Use ALL of these, scattered across the codebase:

| Feature | Where |
|---|---|
| `SCREEN SECTION` + PF-key nav | UI programs |
| `CALL` between programs | Cross-module flow |
| `COPYBOOKS` | Shared record layouts |
| Indexed file I/O | Customer, account, transaction files |
| Simulated embedded SQL | Batch/report programs |
| Variable prefixes | Hungarian-style (WS-, CD-, FD-, etc.) |
| Long paragraphs, `GOTO` | Business logic |
| `PERFORM THRU` | Paragraph ranges |
| `EVALUATE` | Multi-condition branching |
| `88` levels | Condition names |
| `OCCURS` | Table processing |
| `REDEFINES` | Overlapping layouts |
| `COMP-3` / Packed Decimal | Financial amounts |
| Enterprise scale | Multiple subsystems (loans, deposits, teller, reports, batch, security) |

## Style Conventions to Enforce

- 80-column lines preferred, 132 max
- COBOL columns: Area A (8-11), Area B (12-72)
- Mix of uppercase/lowercase across programs (different teams)
- Mix of indentation styles (different eras/teams)
- Meaningless comments preserved, sparse comments elsewhere
- **NO**: `END-IF` on same line as statement, inline `PERFORM`, `INITIALIZE`, modern `FUNCTION` calls
- **YES**: Nested `IF`/`ELSE` with period terminators, `MOVE CORR` only where period-accurate

## Verification Commands

(None yet — repo empty. Once populated, likely `cob -c` for compile checks.)

## Directory Layout

```
src/
├── copybooks/   — 26 COPYBOOKS (FD + funcional)
├── common/      — 10 programas comunes (COMMENU, COMDATE, etc.)
├── security/    — 2 programas seguridad (BNK0001, BNK0010)
├── custmod/     — Customer maintenance (CUSMNU00, etc.)
├── acctmod/     — Account maintenance (ACTMNU00, etc.)
├── teller/      — Teller transaction system (TLRMNU00, etc.)
├── loans/       — Loan origination & servicing (LONMNU00, etc.)
├── deposits/    — Deposit & savings (DEPMNU00, etc.)
├── timedep/     — Time deposits / CDs (TDMNU000, etc.)
├── transfer/    — Transfers wire/ACH/internal (FTMNU000, etc.)
├── cards/       — Card management (CRD programs)
├── admin/       — Administrative programs
├── batch/       — Nightly batch, interest calc (BCHMNU00, etc.)
├── reports/     — Reports (RPTMNU00, etc.)
├── audit/       — Audit trail (AUDTRL00, etc.)
└── data/        — Indexed file data files
docs/            — Documentation (navigation map, data dictionary, etc.)
diagrams/        — PlantUML diagrams (component, navigation, entity, CALL)
tests/           — Test cases and test data
```

## Constraints

- Zero modern COBOL syntax. No Angular, no generated code, no refactoring into clean patterns.
- Realistic inconsistencies welcome — different naming conventions, comment styles, error-handling approaches across subsystems.
- Must compile under Micro Focus COBOL. Avoid GnuCOBOL-specific syntax.
