# BEACON COMPUTING INITIATIVE — BCIEcho
**Developer Seal:** `CJB-DEV-2026`  
**Project:** BCIEcho — Passive Acoustic Sensing & Spatial Survey  
**Status:** Recovered source baseline; not a verified production release  
**Published:** 2026-10-25

BCIEcho is a local-first acoustic observation application for Linux/Kali. Its Python capture and digital-signal-processing modules support a Qt-based desktop interface, microphone discovery, ambient-level telemetry, and a manually positioned room-survey visualization.

## Source provenance

The complete **BCIEcho v2.3 Neon Red Survey Guide Kali** archive has been verified in project history, but its extracted main application source is **not yet committed here**. The current repository contains project documentation, two separately preserved patches, and the guarded Kali source-publishing script. The local working-tree source must be synchronized to complete publication. The archive SHA-256 is:

```text
2d6d94b796b8265019f02f0ebc4626e786caebcfc50dc8c70662e95a23c45ec1  BCIEcho-v2.3-Neon-Red-Survey-Guide-Kali.zip
```

The archive's original `SHA256SUMS.txt` passed `sha256sum -c` when checked against its extracted content. Standalone **v2.1.4** boot-configuration and **v2.1.5** spatial-results patch scripts were saved later and must be treated as **unmerged recovery patches**, not verified integrations. The current on-device Kali working tree has not been inspected by this GitHub snapshot.

## Expected application components (pending source synchronization)

- `main_qml.py`, `qml/`, `bciecho_qml/`: PySide6/Qt Quick interface and backend bridge.
- `main.py`, `bciecho/gui.py`: legacy PyQt6 interface.
- `bciecho/capture.py`, `bciecho/bluetooth_audio.py`, `bciecho/discovery.py`: acquisition and device discovery.
- `bciecho/dsp.py`, `bciecho/calibration.py`, `bciecho/survey.py`, `bciecho/room_view.py`: digital processing and room-survey routines.
- `tests/`: archived unit tests.
- `recovery/patches/`: separately preserved development patch scripts.

## Completing the local-source publication

Run the reviewed `scripts/publish-from-kali.sh` on the Kali host that contains `~/BCIEcho`. It verifies the local entry points, stages selected source files, excludes common sensitive artifacts, records SHA-256 hashes, and pushes a normal commit to `main`. GitHub authentication with `gh` is required.

## Running locally (once source is committed)

```bash
# BEACON COMPUTING INITIATIVE | Developer Seal: CJB-DEV-2026
sudo apt install -y python3-venv libportaudio2 portaudio19-dev
python3 -m venv .venv-qml
.venv-qml/bin/python -m pip install -r requirements-qml.txt
.venv-qml/bin/python main_qml.py
```

Legacy GUI requires a separate environment satisfying `requirements.txt`.

## Verification and limitations

- Archived ZIP integrity check: **PASS** (all 36 archived entries listed in its manifest).
- Python syntax compilation: **PASS**.
- Unit suite: **NOT COMPLETE** in the publishing environment (PyQt6 missing; 2 errors during test collection).
- Live microphones and Qt 3D rendering on Kali: **NOT VERIFIED** by this publication.
- Bluetooth/USB independent clocks and variable transport latency prevent defensible unsynchronized acoustic-source localization. Room images show *observations at measurement positions*, not proven source locations.
- Do not commit recordings, room survey results, machine-specific profiles, access keys, `.env` files, or other personal telemetry.

## Design and attribution

**Beacon Computing Initiative — BCI Development Division**  
Developer Seal: `CJB-DEV-2026`

**Observe accurately · Preserve faithfully · Analyze transparently · Communicate securely · Act deliberately.**
