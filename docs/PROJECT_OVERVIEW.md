# BEACON COMPUTING INITIATIVE | BCIEcho - Detailed Project Overview
**Developer Seal:** `CJB-DEV-2026`  
**Owner:** BCI Development Division  
**Lead Developer:** Chance Joaquin Boone  
**Status:** Engineering architecture / product specification; not a statement of live implementation  
**Last updated:** 2026-10-25

## 1. Executive definition

BCIEcho is a modular Linux/Kali desktop acoustic observation and room-survey system. It aims to combine user-verified sensor positions, passive microphone measurements, relative signal analysis and an interactive three-dimensional room model. The operator should be able to see which measurements are valid, where the microphones physically were, how the environment changed over time, and which conclusions remain unsupported.

This is a separate product line from BCIWhisper and BCIStudio. It is not a transcription service, active acoustic sonar, remote surveillance product, or validated acoustic localization instrument. The name Echo refers to acoustic response and environment analysis; the icon is a conceptual representation of propagation/reflections, not experimental evidence.

## 2. Primary goals and non-goals

**Goals:** auditable passive collection; independent microphone transport; explicit calibration and quality assessment; user-controlled survey geometry; room visualization of measured positions; nonblocking GUI; reproducible local reports; separation of measured quantities from assumptions; privacy-first source publication.

**Non-goals:** guaranteed direction finding from two unsynchronized microphones; direct comparison of digital dBFS readings to acoustic dB SPL without calibration; hidden recording; identifying persons or speech content; attributing sounds to neighbors, equipment, rooms or individuals without corroborating measurement methods.

## 3. Operational scenarios

**Single-device survey.** The user selects a USB microphone, defines room reference dimensions, positions the microphone at point A, confirms placement, records a bounded measurement, and repeats at other points. Each point is plotted with its own relative reading and capture-quality notes.

**Optional Bluetooth comparison.** The user selects a supported available Bluetooth headset microphone as a second independent source. Each source is logged with its own sample rate, clock behavior, latency information and device status. Comparisons are descriptive until calibration and synchronization are proven.

**Repeatable mission.** The user chooses a predefined legacy five-position protocol or a variable N-point spatial survey. The intended interface can accept one or more timed cycles per position. A three-cycle, 30-second experimental preset is a requested target, not a documented verified build.

**Results review.** After completion, an operator opens a saved report, orbits/zooms a room model, selects a plotted point, inspects its dBFS summary and metadata, and sees warnings for incomplete, invalid or incomparable data.

## 4. Architectural layers

| Layer | Responsibility | Boundary / failure behavior |
| --- | --- | --- |
| Device discovery | Enumerate compatible USB and Bluetooth input devices and resolve stable UI labels | Device disappearance is an explicit state, not silently relabeled |
| Audio transport | Acquire bounded blocks at documented format/sample rate from each selected stream | No UI thread capture; no reused stale buffers |
| Capture quality | Track monotonic timestamps, clip rate, missing frames, dropouts, muted/frozen data and effective gain | Invalid blocks excluded from valid summaries |
| Sync evaluator | Measure or estimate per-stream clock drift, buffer backlog and startup/transport latency | Absence of sync forbids arrival-time localization |
| DSP | Calculate relative RMS, peak, dBFS, spectrum and carefully characterized features | State units, window lengths and processing latency |
| Calibration | Record equipment setup, ambient baseline and per-device calibrations | Uncalibrated comparison labeled clearly |
| Survey coordinator | Own mission state, point order, confirmation gating, per-point duration and progress | No background recording without explicit start |
| Spatial model | Store user-entered room dimensions and normalized XYZ sample positions | Coordinates are survey inputs, not estimates of emitter positions |
| Qt bridge and GUI | Expose acquisition state/telemetry and render nonblocking interactive views | Recover gracefully from invalid backend state |
| Local persistence | Save schema-versioned sessions and human-readable diagnostics | Atomic writes; no secrets in logs |
| Verification and publish | Tests, checksums, artifact provenance, redaction gates | Do not advertise a release on partial checks |

Proposed ownership must be reconciled against recovered code before modules are renamed or restructured. Historical modules were described as `bciecho/capture.py`, `bciecho/bluetooth_audio.py`, `bciecho/discovery.py`, `bciecho/dsp.py`, `bciecho/calibration.py`, `bciecho/survey.py`, `bciecho/room_view.py`, `bciecho_qml/bridge.py`, `qml/Main.qml`, `main_qml.py` and a legacy `main.py`. These paths are **currently absent from the remote branch**.

## 5. Capture lifecycle and state contracts

The conceptual state machine is `IDLE -> DISCOVERING -> CONFIGURED -> READY -> CAPTURING -> REVIEW -> SAVED`. Exceptional edges lead to `DEVICE_LOST`, `CALIBRATION_REQUIRED`, `CANCELLED` or `ERROR`, with explicit recovery.

- A point is **READY if and only if** a user-confirmed position, eligible microphone and valid session configuration are present.
- A measurement is **VALID if and only if** acquisition produced sufficient non-corrupt samples, its declared duration and sample-rate accounting pass validation, and quality flags permit inclusion.
- A survey is **COMPLETE if and only if** each required point has either a valid measurement or a deliberately documented exception under the chosen completion policy.
- A two-device comparison is **TIME-ALIGNED if and only if** clocks, timestamps and end-to-end latency uncertainty have been measured and found within the tolerance of the specific analysis.
- A release is **VERIFIED if and only if** published source, dependency pinning, automated tests, hardware smoke tests and provenance checks pass.

The inverse of these gates must also be enforced. Unknown or negative status is not success.

## 6. Sensor and transport architecture

USB devices generally provide a lower-variability capture path than Bluetooth, but both require health checks. The planned discovery UI should present only relevant selectable input devices (the USB microphone and available Bluetooth headset), permit refresh and explicit selection, and report which endpoint is active.

Each device gets independent buffering and telemetry. Suggested telemetry fields include logical device label, transport family, negotiated sample rate, channels, frames captured, frames dropped, monotonic start/end times, buffer backlog and error codes. Processing must not assume that microphone A and B start together or that equal sample counts imply common wall-clock time.

For a muted Bluetooth input or a meter pinned to a display floor (historically reported as -120 dBFS), inspect device presence, profile selection, source mute state, frames arriving, per-block RMS and Bluetooth voice-profile suppression in that order. A flatline should produce an acquisition warning rather than a phantom quiet-room result.

## 7. Signal-processing specification

**Digital level:** compute RMS over defined blocks and present `20 log10(RMS / full_scale)` dBFS with proper handling of zeros and clipping. The exact display floor is a UI convention, not the actual minimum physical pressure.

**Spectrum:** STFT windows and hop lengths should be documented. Level and spectral displays must identify analysis windows and avoid making frequency-specific statements from insufficient signal.

**Acoustic response:** reflection or reverberation features require method descriptions, repeatability, noise control and uncertainty. Passive recordings alone usually do not reveal unique wall distances; techniques relying on controlled stimulus or known excitation must not be advertised as passive-only results.

**Calibration:** keep per-microphone gain, baseline, conditions and reference measurement metadata. Convert to dB SPL only with a defensible acoustic calibration chain. Otherwise preserve all level values as relative digital measurements.

## 8. Survey model and geometry

The intended survey stores: a stable mission identifier, schema version, creation time, operator-configured room dimensions, a room-coordinate convention, named point IDs, normalized or dimensioned XYZ coordinates, capture duration, device ID aliases, processing settings, valid sample counts, dBFS statistics and quality flags. IDs and geometry should use clear units and origin definitions.

A point is a **manual sensor-placement observation**. Values entered by the user describe the microphone's position in an abstract model. The 3D rendering may color markers by a normalized range across a session, but its legend must explicitly say **relative dBFS within this survey**. A heatmap is interpolation, not a directly measured full-space field. Do not transform a sparse set of readings into a visually authoritative source-location map.

The preserved v2.1.4 patch outlines selectable spatial/legacy modes, configurable point count (1-1000 in its UI) and acquisition duration (5-600 seconds in its UI), plus microphone selection and boot-screen initialization. These are patch **intentions**, not verified deployed capabilities.

The preserved v2.1.5 patch outlines `SpatialResults.qml` with an orbitable 3D reference room, measured XYZ markers, selection panel, normalized dBFS colors and loading of a completed report. Its 3D markers represent positions and explicitly do not locate sources. The patch targets specific source anchors and is not integrated into the current remote tree.

## 9. QML experience and presentation contract

The future Qt Quick interface should avoid multiple unintended windows and remain responsive while audio is acquired. Proposed screens include: branded mission initialization, device status and calibration, room-geometry/position editor, capture progress, interactive 3D measurements, saved survey browser and diagnostic telemetry.

The operator must be able to set measurement points interactively, select previously plotted positions, reposition hardware between cycles, and detect missing samples. Present both device state and quality indicators; do not hide drift or suppression behind a polished visualization.

**BCIEcho visual system:** onyx surfaces, cerulean primary indicators, selective red accent or alert markers, Oxanium headings, Rajdhani interface controls and JetBrains Mono numbers/logs. The new icon in `assets/branding/bciecho-icon.webp` depicts a conceptual red/blue acoustic wave within a 3D chamber. It is an asset only: integrating it as a runtime window/taskbar icon requires separate QML/Qt resource wiring and testing.

## 10. Persistence, traceability and privacy

Suggested local records are schema-versioned JSON plus optional efficient numerical blocks, with a manifest linking positions to readings and analysis metadata. Use safe atomic writes, corruption detection and report format versioning. Logs should contain error category, module, UTC timestamp, action taken, recovery outcome and data-quality impact; user-facing errors should be actionable.

Treat captured sound, survey geometry, device identifiers and room context as potentially sensitive. A public code repository must exclude personal recordings, measurements, logs, token material and `.env` files. Hash and review publishable source artifacts. Archive private sessions outside the public repository.

## 11. Performance and resilience

Audio transport must remain independent of expensive GUI animation or 3D rendering. Prefer bounded queues/ring buffers, coalesced UI telemetry, predictable shutoff, lifecycle-safe capture workers and explicit backpressure policy. Prioritize dropping optional visualization frames over silently discarding measurement data. Detect uncaught exceptions, stream loss, leaked capture processes and stale measurements.

A causal debugging process should first identify which boundary failed (device -> stream -> buffer -> DSP -> bridge -> render -> persistence), then test root-cause remediation and check for regressions, races and throughput changes.

## 12. Verification and acceptance matrix

| Domain | Required evidence | Current publication |
| --- | --- | --- |
| Source integrity | Published source tree, dependencies, manifest and reproducible checkout | Missing application source |
| Acquisition | Live USB block detection and stop/restart test | Not verified |
| Bluetooth | Device/profile discovery; clear missing, muted and latency behavior | Not verified |
| Signal analysis | DSP unit tests with generated fixed waveforms and known outputs | Historical partial tests only |
| Survey | Point input, correct IDs/XYZ, confirmation and completion gates | Recovery scripts only |
| Visualization | QML startup, 3D load, no duplicate windows, orbit/zoom/selection | Not verified |
| Persistence | Schema validation, atomic save, corrupt-file recovery and reload | Not verified |
| Privacy | Public staged-file review, exclusions and credential checks | Publication script available; no full audit |
| Packaging | Install/run on target Kali machine and release checksums | Not verified |

The project-history document recorded **13 selected tests passing and 3 failing** due to a legacy survey API expectation, while **2 Qt tests were not collected** because PyQt6 was absent. These are archived validation notes, **not current CI or tests rerun for this documentation change**.

## 13. Recovery and release plan

1. Inventory the authoritative local `$HOME/BCIEcho` source and compare it against the remote tree; confirm source is complete and not mixed with the BCIWhisper or BCIStudio repos.
2. Back up and safely publish only the intended, audited source with `scripts/publish-from-kali.sh`; review changes and create checksums.
3. Resolve semantic conflicts between the legacy five-position model, the v2.1.4 dynamic survey patch and the v2.1.5 results patch; do not run scripts blindly.
4. Normalize module contracts, lifecycle/error handling and a schema-versioned report format before UI feature expansion.
5. Run DSP and survey unit tests, Qt/QML and camera interaction tests, USB device tests, Bluetooth state checks, and real hardware capture-to-report end-to-end tests.
6. Prepare packaging, license/usage policy, clean installation documentation, signed or checksum-verified build artifacts and a release only after acceptance gates pass.

## 14. Project provenance and related components

Source archive recorded in project history: `BCIEcho-v2.3-Neon-Red-Survey-Guide-Kali.zip`, SHA-256 `2d6d94b796b8265019f02f0ebc4626e786caebcfc50dc8c70662e95a23c45ec1`. Separate unmerged scripts under `recovery/patches/` represent later patch intentions. Check [CURRENT_STATE.md](CURRENT_STATE.md) for the on-GitHub file reality.

**BCIWhisper** owns speech-centric capture/transcription/processing decisions. **BCIStudio** owns podcast/production/broadcast concerns. **BCIEcho** owns environmental spatial-acoustic surveying and measurement transparency. Integration should not collapse these distinct responsibilities.

## 15. Attribution

**BEACON COMPUTING INITIATIVE**  
**BCI Development Division**  
**Lead Developer:** Chance Joaquin Boone  
**Developer Seal:** `CJB-DEV-2026`  

**Standards:** Observe accurately. Preserve faithfully. Analyze transparently. Communicate securely. Act deliberately.  
**Integrity:** The SHA-256 of this document is recorded in `docs/REPOSITORY_SHA256SUMS.txt`.
