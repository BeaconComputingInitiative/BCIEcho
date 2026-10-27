<!-- BEACON COMPUTING INITIATIVE | Developer Seal: CJB-DEV-2026 | Chance Joaquin Boone -->
<!-- SHA-256: see docs/HYGIENE_SHA256SUMS from the repository root -->

# BCIEcho

<p align="center"><img src="assets/branding/bciecho-icon.webp" width="180" alt="BCIEcho acoustic survey concept"></p>

Passive acoustic observation and user-guided spatial survey project: record where measurements were taken, compare signal characteristics and present uncertainty alongside results.

**Developer:** Chance Joaquin Boone · **Developer Seal:** CJB-DEV-2026  
**Status:** design documentation, branding and recovery patches. The runnable QML application is not present in this GitHub checkout; there is no validated installable release.

## Start here

| Document or path | Purpose |
| --- | --- |
| [Current state](docs/CURRENT_STATE.md) | Published source gaps, archive provenance and historical test failures |
| [Project overview](docs/PROJECT_OVERVIEW.md) | Intended workflow, architecture and acceptance requirements |
| [Branding](assets/branding/BRANDING.md) | Cerulean / onyx identity with red accents |
| `recovery/patches/` | Unmerged historical source transformations; not general installers |
| `scripts/publish-from-kali.sh` | Helper for publishing authoritative local source after inspection |
| [Commit audit](docs/PORTFOLIO_AUDIT.md) | Complete available branch-history inventory |

## Planned workflow

Define room geometry and named sensor positions, validate USB and optional Bluetooth input, calibrate each device, confirm physical placement before each measurement, and review relative levels with timing and quality metadata. The planned interface uses PySide6 / QML / Qt Quick 3D and keeps capture separate from rendering.

Measurement coordinates represent sensor placements. They do not establish a sound source's position. dBFS is digital level, not calibrated sound pressure; independent USB/Bluetooth clocks, latency and signal processing constrain comparisons.

## Next acceptance gate

Publish the authoritative application source and dependency definitions, resolve the recorded survey-test mismatch, then verify GUI startup and physical microphone capture. The two recovery patches remain distinct because they target different source transformations. They are retained for provenance until matched against the actual application.

There is no runnable installation command for this checkout. Read [CURRENT_STATE.md](docs/CURRENT_STATE.md) before attempting recovery or publication. Release if and only if the exact application revision passes its documented acceptance gates.

Observe accurately. Preserve faithfully. Analyze transparently. Communicate securely. Act deliberately.
