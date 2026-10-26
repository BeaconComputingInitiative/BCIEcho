#!/usr/bin/env bash
set -Eeuo pipefail
cd "$HOME/BCIEcho"
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP="backups/boot-v214-$STAMP"
mkdir -p "$BACKUP" logs qml
cp -a qml/Main.qml "$BACKUP/Main.qml"
if [[ -f qml/BootConfiguration.qml ]]; then cp -a qml/BootConfiguration.qml "$BACKUP/BootConfiguration.qml"; fi
./.venv-qml/bin/python - <<'PY'
from pathlib import Path
p=Path('qml/BootConfiguration.qml')
p.write_text('''import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: boot
    signal initialize(int points, real duration, string mode)
    property color cyan: "#00C8ED"
    property color ink: "#080E19"
    property color pale: "#DDF5FF"
    Rectangle { anchors.fill: parent; color: boot.ink }
    // Layered concentric acoustic telemetry rings; no extra window or audio stream.
    Item {
        id: radar
        width: Math.min(parent.width * 0.53, 610); height: width
        anchors.right: parent.right; anchors.rightMargin: 22
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0.78
        Repeater {
            model: 7
            Rectangle {
                required property int index
                width: radar.width * (0.27 + index * 0.105)
                height: width; radius: width / 2
                x: (radar.width - width) / 2; y: (radar.height - height) / 2
                color: "transparent"; border.width: index % 2 ? 1 : 2
                border.color: index % 2 ? "#24576D" : "#008AB0"
            }
        }
        Rectangle {
            width: radar.width * 0.36; height: 2; color: boot.cyan
            anchors.centerIn: parent; transformOrigin: Item.Left
            RotationAnimation on rotation { from: 0; to: 360; duration: 10000; loops: Animation.Infinite }
        }
        Rectangle {
            width: 14; height: 14; radius: 7; color: boot.cyan
            anchors.centerIn: parent
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.25; duration: 650 }
                NumberAnimation { to: 1; duration: 650 }
            }
        }
        Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
            text: "SPATIAL ACQUISITION / CONFIGURATION"; color: "#5BADC8"
            font.family: "JetBrains Mono"; font.pixelSize: 11 }
    }
    ScrollView {
        anchors.left: parent.left; anchors.leftMargin: 52
        anchors.top: parent.top; anchors.topMargin: 36
        anchors.bottom: parent.bottom; anchors.bottomMargin: 24
        width: Math.min(parent.width * 0.52, 660)
        clip: true
        ColumnLayout {
            width: Math.min(boot.width * 0.52, 650); spacing: 13
            Text { text: "BEACON COMPUTING INITIATIVE"; color: boot.cyan
                font.family: "Rajdhani"; font.pixelSize: 19; font.bold: true }
            Text { text: "BCIECHO"; color: boot.pale
                font.family: "Oxanium"; font.pixelSize: 66; font.bold: true }
            Text { text: "ACOUSTIC SPATIAL INTELLIGENCE  /  v2.1.4"; color: "#84BCD1"
                font.family: "JetBrains Mono"; font.pixelSize: 12 }
            Rectangle { Layout.fillWidth: true; height: 2; color: "#145C78" }
            Text { text: "MISSION INITIALIZATION"; color: boot.pale
                font.family: "Oxanium"; font.pixelSize: 23; font.bold: true }
            Text { text: "Configure your acoustic survey before entering the observatory.\nRecording begins only after explicit confirmation in the workspace."
                color: "#9CB9CA"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            Text { text: "SURVEY MODE"; color: boot.cyan; font.bold: true }
            ComboBox { id: mode; Layout.fillWidth: true
                model: ["SPATIAL 3D", "LEGACY 5-POSITION"]
                onCurrentIndexChanged: if (currentIndex === 1) points.value = 5 }
            RowLayout { Layout.fillWidth: true; spacing: 16
                ColumnLayout { Layout.fillWidth: true
                    Text { text: "MEASUREMENT POINTS"; color: boot.cyan; font.bold: true }
                    SpinBox { id: points; Layout.fillWidth: true; from: 1; to: 1000; value: 10
                        enabled: mode.currentIndex === 0 }
                }
                ColumnLayout { Layout.fillWidth: true
                    Text { text: "SECONDS PER POINT"; color: boot.cyan; font.bold: true }
                    SpinBox { id: seconds; Layout.fillWidth: true; from: 5; to: 600; value: 60 }
                }
            }
            Text { text: "USB MICROPHONE"; color: boot.cyan; font.bold: true }
            ComboBox { id: mic; Layout.fillWidth: true
                model: backend.usbOptions; textRole: "label"; valueRole: "id"
                onActivated: if (currentIndex >= 0) backend.selectDevice("A", backend.usbOptions[currentIndex].id) }
            Text { Layout.fillWidth: true; wrapMode: Text.WordWrap
                text: "DEVICE STATUS  /  " + backend.usbStatus
                color: backend.usbStatus === "ACTIVE" ? "#67E6BB" : "#F0C47B"
                font.family: "JetBrains Mono" }
            Button { Layout.fillWidth: true; text: "REFRESH MICROPHONES"
                onClicked: backend.refresh() }
            Button { Layout.fillWidth: true; Layout.preferredHeight: 58
                text: "INITIALIZE BCIECHO  →"
                onClicked: boot.initialize(points.value, seconds.value,
                    mode.currentIndex === 0 ? "spatial" : "legacy") }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#145C78" }
            Text { text: "CHANCE JOAQUIN BOONE"; color: boot.pale
                font.family: "Oxanium"; font.bold: true; font.pixelSize: 19 }
            Text { text: "FOUNDER & LEAD DEVELOPER  •  BCI DEVELOPMENT DIVISION"
                color: "#88B8CA"; font.pixelSize: 12 }
            Text { text: "DEVELOPER SEAL  /  CJB-DEV-2026"
                color: boot.cyan; font.family: "JetBrains Mono"; font.pixelSize: 12 }
        }
    }
}
''')
p=Path('qml/Main.qml'); s=p.read_text()
if 'property bool bootActive:' in s: raise SystemExit('Already installed: bootActive exists')
needle='    property int selectedTab: 0'
assert s.count(needle)==1, 'Main.qml property anchor mismatch'
s=s.replace(needle,needle+'\n    property bool bootActive: true\n    property string missionMode: "spatial"')
needle='    ColumnLayout {\n        anchors.fill: parent; anchors.margins: 18; spacing: 12'
assert s.count(needle)==1, 'Main layout anchor mismatch'
s=s.replace(needle,needle+'\n        visible: !win.bootActive')
s=s.replace('"CYCLE " + backend.surveyCycle + "/5  •  "','"CYCLE " + backend.surveyCycle + "/" + backend.surveyPointCount + "  •  "')
s=s.replace('"03  /  FIVE-POSITION SURVEY"','"03  /  " + backend.surveyPointCount + "-POINT SURVEY"')
s=s.replace('"60 SECONDS PER POSITION  •  REPOSITION BETWEEN CYCLES"','backend.surveyDuration.toFixed(0) + " SECONDS PER POSITION  •  REPOSITION BETWEEN CYCLES"')
s=s.replace('Repeater { model: ["CENTER", "NORTH", "EAST", "SOUTH", "WEST"]','Repeater { model: backend.surveyPoints')
s=s.replace('required property int index; required property string modelData','required property int index; required property var modelData')
s=s.replace(' + "   " + modelData; color:', ' + "   " + modelData.name.toUpperCase(); color:')
s=s.replace('from: 0; to: 60; value: 60-backend.surveyRemaining','from: 0; to: backend.surveyDuration; value: backend.surveyDuration-backend.surveyRemaining')
s=s.replace('"CONFIRM POSITION  /  RECORD 60s"','"CONFIRM POSITION  /  RECORD " + backend.surveyDuration.toFixed(0) + "s"')
s=s.replace('"Move the microphone to the indicated position and confirm. The room image is generated after all five valid measurements."','"Move the microphone to the indicated position and confirm. Each point records relative acoustic energy (dBFS)."')
# Keep legacy-only components from misleading spatial-mode users.
s=s.replace('                            SurveyGuide {','                            SurveyGuide {\n                                visible: win.missionMode === "legacy"')
s=s.replace('"● VERIFIED FIVE-POSITION DATA"','"● VERIFIED SURVEY DATA"')
s=s.replace('"Complete all five 60-second cycles to generate the acoustic image."','"Complete all configured measurements to generate the acoustic results."')
# Results visualizer is legacy-only; its assumptions do not represent arbitrary 3D positions.
s=s.replace('visible: backend.hasReconstruction; results: backend.wallResults','visible: backend.hasReconstruction && win.missionMode === "legacy"; results: backend.wallResults')
assert s.rstrip().endswith('}'), 'Window closing brace missing'
idx=s.rfind('}')
s=s[:idx]+'''    BootConfiguration {
        id: bootScreen
        anchors.fill: parent
        visible: win.bootActive
        z: 100
        onInitialize: function(count, duration, mode) {
            if (backend.surveyPhase === "listening") return
            backend.configureSpatialSurvey(count, duration)
            if (backend.surveyPointCount !== count || backend.surveyDuration !== duration) return
            win.missionMode = mode
            win.selectedTab = 0
            win.bootActive = false
        }
    }
'''+s[idx:]
p.write_text(s)
print('[PASS] Boot screen and dynamic survey UI installed')
PY
if ! ./.venv-qml/bin/python -m pytest -q tests/test_spatial_v213.py tests/test_survey_v21.py; then
  cp -a "$BACKUP/Main.qml" qml/Main.qml
  if [[ -f "$BACKUP/BootConfiguration.qml" ]]; then cp -a "$BACKUP/BootConfiguration.qml" qml/BootConfiguration.qml; else rm -f qml/BootConfiguration.qml; fi
  echo '[ERROR] Tests failed, QML restored'; exit 1
fi
sha256sum qml/Main.qml qml/BootConfiguration.qml | tee "logs/v214-$STAMP.sha256"
echo '[BCIEcho] Boot rebuild installed. Start: ./.venv-qml/bin/python main_qml.py'
echo '[BCIEcho] Verify boot rendering, dynamic count and microphone behavior in the GUI.'