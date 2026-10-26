# BEACON COMPUTING INITIATIVE — BCIEcho
**Developer Seal:** `CJB-DEV-2026`  
**Snapshot date:** 2026-10-25

## Recovered source state

The repository includes the complete files extracted from the **v2.3 Neon Red Survey Guide Kali** package. This is a **recovered development baseline**, not a confirmed copy of the current local Kali working tree.

Later development patches are stored separately:
- `recovery/patches/BCIEcho-v214-rebuild.sh` — boot/configuration UI, dynamic survey controls; unmerged.
- `recovery/patches/BCIEcho-v215-spatial-results.sh` — spatial results Qt Quick 3D view and survey-load changes; unmerged.

The patches target a newer local tree and **must not be run blindly against this archive**.

## Verification

- SHA-256 checksums of all archived v2.3 files: **PASS**.
- Python syntax compilation of extracted sources: **PASS**.
- Selected tests not requiring Qt GUI: **13 passed, 3 failed**; the failures are three legacy survey tests assuming the older 3-cycle API.
- Full suite: **unable to collect 2 Qt tests** in current validation environment because PyQt6 is not installed.
- Qt runtime, microphones, Bluetooth capture and 3D rendering on Kali: **not verified** in this publication.

## Technical interpretation

USB/Bluetooth microphones may run on independent sample clocks with variable capture latency and different processing/gains. Measured dBFS intensities are not calibrated acoustic pressure measurements, and visualizations of measurement position are not proof of sound-source location.

## Local state needed for the actual current snapshot

Local project: `/home/chance/BCIEcho`

Do not commit `.venv`, recordings, personal survey JSON, logs, machine-specific secrets, or unreconciled binary artifacts. After inspecting the local tree, publish source changes to GitHub and run the system's actual integration tests.

## Provenance fingerprints

```text
2d6d94b796b8265019f02f0ebc4626e786caebcfc50dc8c70662e95a23c45ec1  BCIEcho-v2.3-Neon-Red-Survey-Guide-Kali.zip
52098ada3b202fcb9f4fa6160af26a64ae1642884bfece5ddb75d3a939115d5a  BCIEcho-v214-rebuild.sh
9a1886dc8c13d3a82fc9aea561bbed2ebf4c0ee0e294d2a9231b4f1789bd00c5  BCIEcho-v215-spatial-results.sh
```

**BCI standards:** Observe accurately · Preserve faithfully · Analyze transparently · Communicate securely · Act deliberately.
