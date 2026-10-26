# BEACON COMPUTING INITIATIVE | BCIEcho
**Developer Seal:** `CJB-DEV-2026`  
**Founder / Lead Developer:** Chance Joaquin Boone  
**Division:** BCI Development Division  
**Repository state:** Documentation and recovery snapshot; application source is NOT yet present in this GitHub tree  
**Documentation updated:** 2026-10-25

<p align="center"><img src="assets/branding/bciecho-icon.webp" width="192" alt="BCIEcho branded icon: cerulean acoustic waves, red highlights, and an onyx 3D survey chamber"></p>

**BCIEcho** is a standalone, local-first application project for **passive acoustic sensing, environmental sound observation, and user-guided three-dimensional spatial surveying**. It is developed as part of the **Beacon Computing Initiative (BCI)** and is separate from BCIWhisper (transcription/audio enhancement) and BCIStudio (production and broadcast).

The objective is to turn microphone measurements collected at documented physical positions into understandable, reproducible acoustic observations: which position was measured, which microphone was used, how the signal level changed, and how much confidence the data supports. BCIEcho is **not** an active sonar device and its conceptual echo-wave artwork does not imply active emissions or proven sound-source coordinates.

> **Publication notice:** The current remote repository contains documentation, recovery patch scripts and a Kali publication script. It does **not** yet contain the application modules referenced below. The verified status is detailed in [CURRENT_STATE](docs/CURRENT_STATE.md); the complete intended system design is in [PROJECT_OVERVIEW](docs/PROJECT_OVERVIEW.md). Treat features below as requirements, architecture targets, or previously recovered source descriptions unless explicitly marked as verified on this remote branch.

## Mission and intended uses

BCIEcho is designed for repeatable room surveys, acoustic environment comparisons, ambient intensity logging, reflection/reverberation exploration, microphone performance evaluation, and interactive visualization of measurements. Its core workflow is **observe -> record provenance -> analyze -> present uncertainty -> let the user decide**.

Unlike speech-to-text software, it focuses on **where and under what conditions sound was measured**, not on interpreting spoken conversations. It should require explicit user control before beginning a survey and avoid claiming that a simple microphone level reveals the location or identity of a source.

## Core capabilities and development status

| Capability | Functional specification | Remote state |
| --- | --- | --- |
| Local microphone discovery | Enumerate relevant USB input and available Bluetooth microphone choices with readable status | Application module not published |
| USB acoustic capture | Stream microphone samples via local audio backends into an isolated, bounded acquisition path | Application module not published |
| Optional dual-input mode | Capture USB and Bluetooth independently; report drift, buffering and latency rather than assume synchronization | Design target; not hardware-verified |
| Ambient signal analysis | Show levels in dBFS, clipping, silence, spectral content and acquisition quality | Design target / archived project behavior |
| User-guided room survey | Ask users to establish room boundaries, assign position names, and record measurements at confirmed locations | Recovery patch design; not merged |
| Configurable survey sessions | Support a configurable number of 3D points and per-point recording durations, retaining legacy five-position workflows as needed | v2.1.4 patch stored, not merged |
| 3D survey results | Plot sampled points in a navigable room model, with relative-level coloration and inspectable sample records | v2.1.5 patch stored, not merged |
| Local report storage | Keep measurement records, device context, analysis metadata, and recovery-friendly export formats | Design target / recovered source references |
| Calibration and synchronization | Validate levels, latency, drift and noise suppression separately for each device | Incomplete; do not infer localization |
| Transparency and diagnostics | Record device and processing failures, distinguish missing data from measured silence, and make tests reproducible | Required acceptance criterion |

## How the product is intended to operate

1. **Initialize a mission.** Choose the survey mode, planned positions or point count, and duration. Starting the interface is not consent to begin audio capture.
2. **Discover inputs.** Identify the USB microphone and any available Bluetooth headset microphone. A disconnected or silent device must not be silently treated as valid data.
3. **Establish geometry.** Enter approximate room dimensions and user-selected reference points; mark the origin, walls and measurement positions. Coordinates describe **where the operator placed the sensor**, not where sound originated.
4. **Calibrate.** Measure per-device noise floor, gain behavior, clipping, latency and drift where possible; annotate confidence and known limitations.
5. **Capture a point.** Ask the user to confirm physical microphone placement before each acquisition cycle. Keep independent timing and quality metadata for each stream.
6. **Analyze observations.** Compute relative digital audio levels, trends and optional spectral/reverberant descriptors only from usable samples.
7. **Visualize and review.** Display points inside the room, support camera orbit and zoom, show selected-point readings, flag invalid or incomplete samples, and export local results.
8. **Repeat or compare.** Preserve a reproducible session trail for additional positions and multi-cycle surveys, including a possible three-cycle, 30-second-per-cycle protocol after validation.

### Intended data flow

    Physical microphone(s)
        -> audio backend / stream acquisition
        -> per-device ring buffer and capture timestamps
        -> signal integrity checks / calibration metadata
        -> DSP features and relative dBFS summaries
        -> survey position and session records
        -> Qt Quick user interface / 3D point visualization
        -> local reports and transparent diagnostic logs

Each module is expected to own one well-defined stage. UI rendering must not block capture or corrupt buffered samples.

## Interface and visual identity

The desktop interface targets **PySide6 + QML / Qt Quick / Qt Quick 3D**, with a separate legacy **PyQt6** implementation in older source history. BCIEcho branding uses **cerulean blue**, **onyx black** and selective **red accents**. BCI typography is **Oxanium** for titles, **Rajdhani** for general UI, and **JetBrains Mono** for technical telemetry.

The red-accented official project icon is committed at [assets/branding/bciecho-icon.webp](assets/branding/bciecho-icon.webp). It visualizes acoustic waves inside a room-scale analysis chamber. It is illustrative branding, not a sample of measured field data. See [branding specifications](assets/branding/BRANDING.md).

## Engineering architecture

The planned functional boundaries are:

- **Acquisition and discovery:** independent USB/Bluetooth enumerators, audio transport, input selection, buffer ownership and disconnect handling.
- **Signal processing:** level meters, spectrum and relevant environmental descriptors with clear units and operating ranges.
- **Calibration and synchronization:** per-device noise/gain baselines, clock assessment, timestamps, and drift/latency reporting.
- **Spatial survey:** user-entered geometry, named XYZ points, guided position confirmation, sample aggregation and session state.
- **Visualization:** Qt/QML screens, nonblocking status updates, room reference geometry, measurement markers, tooltips and selectable results.
- **Persistence and diagnostics:** local survey records, provenance, integrity checks, error categories, and privacy-aware logs.
- **Tests and publication:** deterministic DSP tests, GUI/bridge tests, representative fixtures, deployment scripts and hash manifests.

Architectural details, example records, module ownership and release gates appear in [PROJECT_OVERVIEW.md](docs/PROJECT_OVERVIEW.md).

## What exists in this GitHub checkout

This branch currently exposes the README, `.gitignore`, `docs/`, `recovery/patches/`, and `scripts/publish-from-kali.sh`, plus project branding. **The referenced local application files are not here yet.** The publication script is intended to import allowed source files from an operator-controlled Kali working tree after safety checks; it does not itself prove that those files were pushed.

Previously discussed local source modules include `main_qml.py`, `qml/`, `bciecho_qml/`, `main.py`, `bciecho/`, and `tests/`. These names document expected source boundaries, **not present files**. Do not run the recovered patch scripts without first establishing matching local source baselines; they perform source transformations and may fail or overwrite assumptions from a different revision.

### Provenance

The recorded recovery source was an archive named **BCIEcho-v2.3-Neon-Red-Survey-Guide-Kali.zip**, with historical SHA-256:

    2d6d94b796b8265019f02f0ebc4626e786caebcfc50dc8c70662e95a23c45ec1

The separate `recovery/patches/BCIEcho-v214-rebuild.sh` and `BCIEcho-v215-spatial-results.sh` are **unmerged recovery patches**. Archived validation findings and their limitations are in [CURRENT_STATE.md](docs/CURRENT_STATE.md). Archive and test findings have not been independently re-run as part of this documentation update.

## Local development and running the source

Once the actual application modules and requirements files have been safely published, the intended Kali/Linux QML setup is:

    sudo apt install -y python3-venv libportaudio2 portaudio19-dev
    python3 -m venv .venv-qml
    .venv-qml/bin/python -m pip install -r requirements-qml.txt
    .venv-qml/bin/python main_qml.py

**These commands will not launch the current remote checkout**, because `requirements-qml.txt` and `main_qml.py` are not currently present. Do not interpret this as a release-ready installation guide. Verify runtime permissions, appropriate audio backend, Qt packages, and devices on the target machine. Legacy PyQt6 would require a separate compatible environment.

A source-publication helper is preserved at [scripts/publish-from-kali.sh](scripts/publish-from-kali.sh). Inspect it before use. It requires `git`, `gh`, `rsync`, `sha256sum` and a logged-in GitHub account, and excludes common recording, log, credentials, environment and survey-data paths.

## Measurement integrity and scientific limitations

- **dBFS is digital signal level**, not calibrated dB SPL; readings from different devices are not directly comparable unless calibration supports the comparison.
- Bluetooth transport can introduce unpredictable latency, packet buffering, noise suppression and automatic gain control. USB and Bluetooth typically use independent clocks.
- **A bright 3D marker shows a recorded measurement position**, not a proven source location. Do not claim time-of-arrival positioning from unsynchronized signals.
- An input stuck around a display floor such as `-120 dBFS` may indicate missing data, aggressive suppression or a muted device; first distinguish stream health from true acoustic silence.
- Environmental reflections may be discussed qualitatively, but an impulse response, distance, azimuth or source trajectory requires an explicitly validated measurement method.
- No biometric, voice-identity, forensic or surveillance conclusions should be inferred from the visualization.

## Privacy and operational controls

BCIEcho is designed to remain local-first. Microphone capture should require affirmative user initiation and have a clear stop action. Do not publish raw audio, room geometry tied to private spaces, unredacted logs, per-device identifiers, survey reports, credentials or personal telemetry into this public repository. Raw recordings and survey files should be opt-in, access-limited, and reviewed before export. The `.gitignore` and publication exclusions are helpful safeguards, not a substitute for reviewing staged changes.

## Verification and release policy

A production-ready claim requires, at minimum: the correct source actually present in the repo; a clean install; startup without extra windows or blocking capture; verified live USB capture; explicit Bluetooth availability/error behavior; honest drift/calibration telemetry; guided survey completion; 3D results on supported hardware; session import/export; and a complete passing automated test suite plus hardware integration tests. **Those gates have not been satisfied by this GitHub snapshot.**

## Development roadmap

| Phase | Deliverable | Gate |
| --- | --- | --- |
| 1 - Recover | Publish audited local source, dependencies and tests without private recordings or machine secrets | File inventory, checksums and reproducible import |
| 2 - Integrate | Reconcile v2.1.4 boot/survey UX and v2.1.5 spatial results against the audited source tree | GUI/bridge contracts, regressions and startup tests |
| 3 - Validate | USB and Bluetooth health checks, calibration and honest uncertainty reporting | Device-specific and clock-drift testing |
| 4 - Refine | Interactive spatial point mapping, multiple cycles, persistence, polished cerulean/onyx/red UI | End-to-end user survey tests |
| 5 - Release | Package deployment, CI, release manifests and provenance | Reproducible build and passing acceptance suite |

## Attribution and integrity

**BEACON COMPUTING INITIATIVE - BCI Development Division**  
**Founder and Lead Developer:** Chance Joaquin Boone  
**Developer Seal:** `CJB-DEV-2026`

The SHA-256 hashes for documentation and the committed icon are recorded in [docs/REPOSITORY_SHA256SUMS.txt](docs/REPOSITORY_SHA256SUMS.txt). The optimized icon SHA-256 is `d0b279cbe9d0c0ea717929f37c654043f5f924fe89967656b14224593b61c399`.

**BCI principles:** Observe accurately. Preserve faithfully. Analyze transparently. Communicate securely. Act deliberately.
