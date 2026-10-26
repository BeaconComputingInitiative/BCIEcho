# BEACON COMPUTING INITIATIVE | BCIEcho - Current GitHub State
**Developer Seal:** `CJB-DEV-2026`  
**Snapshot date:** 2026-10-25  
**Scope:** GitHub main branch, not the local Kali working tree

## Grounded remote state

The inspected GitHub branch has `README.md`, `.gitignore`, `docs/CURRENT_STATE.md`, `recovery/patches/BCIEcho-v214-rebuild.sh`, `recovery/patches/BCIEcho-v215-spatial-results.sh`, and `scripts/publish-from-kali.sh`. This documentation/branding update adds `docs/PROJECT_OVERVIEW.md` and `assets/branding/`.

**Critical correction:** The remote branch does **not** currently contain the runnable v2.3 archive contents, the `main_qml.py` entrypoint, the `bciecho/` and `bciecho_qml/` modules, the `qml/` runtime directory, or the dependencies/test suite. An earlier description saying that extracted source files were already in this remote repository was inaccurate; the extracted-source recovery and validation described below occurred outside the currently inspected GitHub tree.

## Recoverable project history

- Recorded archive: `BCIEcho-v2.3-Neon-Red-Survey-Guide-Kali.zip`.
- SHA-256: `2d6d94b796b8265019f02f0ebc4626e786caebcfc50dc8c70662e95a23c45ec1`.
- `recovery/patches/BCIEcho-v214-rebuild.sh`: boot/configuration UI and dynamic survey controls; not merged into published executable code.
- `recovery/patches/BCIEcho-v215-spatial-results.sh`: Qt Quick 3D spatial results and report-load changes; not merged.
- The patch scripts assume specific local files and anchors, so they are **not safe general-purpose installers**.

## Historical verification (not rerun for this update)

- The archived v2.3 ZIP's listed SHA-256 manifest entries passed during the recovery work.
- The extracted Python files passed syntax compilation.
- Selected tests: **13 passed / 3 failed** (three legacy survey tests were based on an older three-cycle API).
- Two Qt tests could not be collected in that validation environment because PyQt6 was absent.
- No fresh runtime validation of USB devices, Bluetooth capture, Qt Quick 3D, or the actual Kali host has been performed by the documentation/branding update.

## Next acceptance gate

Publish and inspect the authoritative local source using a privacy-aware, reviewed workflow; then run source and environment validation. A repository containing only design documents and recovery scripts **must not** be labeled a verified BCIEcho production release.

## Data interpretation

USB and Bluetooth microphone streams generally differ in gain, sample clock, buffering and latency. dBFS is relative digital level, not calibrated acoustic pressure. Spatial markers visualize survey measurement locations supplied by the user, **not proven sound-source positions**. Do not include private recordings, survey exports, locations, logs, device secrets or tokens in a public snapshot.

## Provenance fingerprints

    2d6d94b796b8265019f02f0ebc4626e786caebcfc50dc8c70662e95a23c45ec1  BCIEcho-v2.3-Neon-Red-Survey-Guide-Kali.zip
    52098ada3b202fcb9f4fa6160af26a64ae1642884bfece5ddb75d3a939115d5a  BCIEcho-v214-rebuild.sh
    9a1886dc8c13d3a82fc9aea561bbed2ebf4c0ee0e294d2a9231b4f1789bd00c5  BCIEcho-v215-spatial-results.sh

## Attribution and integrity

**BEACON COMPUTING INITIATIVE | Developer Seal: `CJB-DEV-2026`**  
The SHA-256 of this state document is recorded in `docs/REPOSITORY_SHA256SUMS.txt`.

Observe accurately. Preserve faithfully. Analyze transparently. Communicate securely. Act deliberately.
