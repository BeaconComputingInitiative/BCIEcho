#!/usr/bin/env bash
set -Eeuo pipefail
cd "$HOME/BCIEcho"
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP="backups/spatial-results-v215-$STAMP"
mkdir -p "$BACKUP" logs qml/scenes
cp -a bciecho_qml/bridge.py qml/Main.qml "$BACKUP/"
if [[ -e qml/scenes/SpatialResults.qml ]]; then cp -a qml/scenes/SpatialResults.qml "$BACKUP/"; fi
rollback(){ echo '[BCIEcho][ERROR] Restoring modified files'; cp "$BACKUP/bridge.py" bciecho_qml/bridge.py; cp "$BACKUP/Main.qml" qml/Main.qml; if [[ -e "$BACKUP/SpatialResults.qml" ]]; then cp "$BACKUP/SpatialResults.qml" qml/scenes/SpatialResults.qml; else rm -f qml/scenes/SpatialResults.qml; fi; }
trap rollback ERR
cat > qml/scenes/SpatialResults.qml <<'QML'
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D

Item {
    id: root
    property var measurements: []
    property string reportName: ""
    property int selectedPoint: -1
    property real yaw: 38
    property real pitch: -28
    property real distance: 850
    property real roomWidth: 480
    property real roomDepth: 480
    property real roomHeight: 270
    readonly property color cyan: "#00B8E6"
    function levelColor(db) {
        if (db === null || db === undefined || !isFinite(Number(db))) return "#596B78"
        let vals = []
        for (let i=0; i<measurements.length; i++) {
            let v=Number(measurements[i].mean_dbfs)
            if (measurements[i].mean_dbfs !== null && isFinite(v)) vals.push(v)
        }
        if (!vals.length) return "#596B78"
        let lo=Math.min.apply(null, vals), hi=Math.max.apply(null, vals)
        let t=hi===lo ? 0.5 : Math.max(0,Math.min(1,(Number(db)-lo)/(hi-lo)))
        return Qt.rgba(0.08 + 0.92*t, 0.72*(1-t)+0.15*t, 0.95*(1-t)+0.12*t, 1)
    }
    Rectangle { anchors.fill: parent; color: "#0A1019"; radius: 10 }
    View3D {
        id: view
        anchors.fill: parent
        camera: cam
        environment: SceneEnvironment { clearColor: "#0A1019"; backgroundMode: SceneEnvironment.Color; antialiasingMode: SceneEnvironment.MSAA }
        Node {
            id: orbit
            eulerRotation: Qt.vector3d(root.pitch, root.yaw, 0)
            PerspectiveCamera { id: cam; z: root.distance; clipFar: 10000; clipNear: 1 }
        }
        DirectionalLight { eulerRotation.x: -45; eulerRotation.y: -35; brightness: 1.5 }
        PointLight { y: 180; brightness: 35; color: "#00B8E6" }
        Model {
            source: "#Cube"
            scale: Qt.vector3d(root.roomWidth/100, 0.015, root.roomDepth/100)
            y: -root.roomHeight/2
            materials: PrincipledMaterial { baseColor: "#152E40"; roughness: 0.8 }
        }
        // Open wireframe-like edges; the room is a reference volume, not a measured field.
        Repeater3D {
            model: 4
            delegate: Model {
                required property int index
                source: "#Cube"
                x: index % 2 === 0 ? -root.roomWidth/2 : root.roomWidth/2
                z: index < 2 ? -root.roomDepth/2 : root.roomDepth/2
                scale: Qt.vector3d(0.035, root.roomHeight/100, 0.035)
                materials: PrincipledMaterial { baseColor: "#22657E"; roughness: 0.5 }
            }
        }
        Repeater3D {
            model: root.measurements
            delegate: Node {
                id: pointNode
                required property var modelData
                required property int index
                x: (Number(modelData.x)-0.5)*root.roomWidth
                y: (Number(modelData.y)-0.5)*root.roomHeight
                z: (Number(modelData.z)-0.5)*root.roomDepth
                Model {
                    objectName: "result-marker-" + pointNode.index
                    source: "#Sphere"
                    scale: Qt.vector3d(0.32,0.32,0.32)
                    materials: PrincipledMaterial {
                        baseColor: root.levelColor(pointNode.modelData.mean_dbfs)
                        metalness: 0.15
                        roughness: 0.32
                    }
                }
                Model {
                    source: "#Cylinder"
                    y: (-root.roomHeight/2-pointNode.y)/2
                    scale: Qt.vector3d(0.035,Math.max(0.01,(pointNode.y+root.roomHeight/2)/100),0.035)
                    materials: PrincipledMaterial { baseColor: "#28758B"; roughness: 0.5 }
                }
            }
        }
    }
    MouseArea {
        anchors.fill: view
        property real lastX: 0
        property real lastY: 0
        onPressed: (mouse) => { lastX=mouse.x; lastY=mouse.y }
        onPositionChanged: (mouse) => {
            if (pressed) {
                root.yaw += (mouse.x-lastX)*0.35
                root.pitch = Math.max(-80,Math.min(80,root.pitch+(mouse.y-lastY)*0.3))
                lastX=mouse.x; lastY=mouse.y
            }
        }
        onWheel: (wheel) => { root.distance=Math.max(350,Math.min(2200,root.distance-wheel.angleDelta.y*0.6)); wheel.accepted=true }
    }
    Rectangle {
        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 14
        width: Math.min(parent.width-28, 330); height: 108; radius: 9
        color: "#D9111D2A"; border.color: "#325B70"
        Column { anchors.fill: parent; anchors.margins: 10; spacing: 5
            Text { text: "SPATIAL ACOUSTIC RESULTS"; color: "#00B8E6"; font.bold: true; font.pixelSize: 16 }
            Text { text: root.measurements.length + " measured positions  •  relative dBFS"; color: "#D3E8F0"; font.pixelSize: 12 }
            Text { text: "Drag: orbit  •  Scroll: zoom"; color: "#93AFC0"; font.pixelSize: 12 }
            Text { text: "Markers are measurements, not source locations"; color: "#93AFC0"; font.pixelSize: 11 }
        }
    }
    Rectangle {
        anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.margins: 12
        width: Math.min(255, parent.width*0.35); radius: 9; color: "#E0111D2A"; border.color: "#325B70"
        ColumnLayout { anchors.fill: parent; anchors.margins: 10; spacing: 8
            Text { text: "MEASURED POINTS"; color: "#00B8E6"; font.bold: true; font.pixelSize: 15 }
            ScrollView { Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                Column { width: parent.width; spacing: 4
                    Repeater {
                        model: root.measurements
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: Math.max(120, parent.width-12); height: 39; radius: 5
                            color: root.selectedPoint===index ? "#294D60" : "#172A39"
                            border.color: root.levelColor(modelData.mean_dbfs)
                            Row { anchors.fill: parent; anchors.margins: 8; spacing: 8
                                Rectangle { width: 10; height: 10; radius: 5; anchors.verticalCenter: parent.verticalCenter; color: root.levelColor(modelData.mean_dbfs) }
                                Text { anchors.verticalCenter: parent.verticalCenter; color: "#E3F6FC"; font.pixelSize: 12
                                    text: modelData.name + "  " + (modelData.mean_dbfs===null ? "NO DATA" : Number(modelData.mean_dbfs).toFixed(2)+" dBFS") }
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.selectedPoint=index }
                        }
                    }
                }
            }
            Text { visible: root.selectedPoint>=0 && root.selectedPoint<root.measurements.length
                color: "#9DBBCB"; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true
                text: {
                    if (root.selectedPoint<0 || root.selectedPoint>=root.measurements.length) return ""
                    let p=root.measurements[root.selectedPoint]
                    return "Samples: "+p.samples+"\nXYZ: "+Number(p.x).toFixed(3)+", "+Number(p.y).toFixed(3)+", "+Number(p.z).toFixed(3)
                }
            }
        }
    }
}
QML
./.venv-qml/bin/python - <<'PY'
from pathlib import Path
p=Path('bciecho_qml/bridge.py'); s=p.read_text()
anchor='    @Property(bool,notify=changed)\n    def hasReconstruction(self):'
assert s.count(anchor)==1, 'Bridge results insertion anchor changed'
addition='''    @Property('QVariantList',notify=changed)
    def spatialResults(self):
        summaries=self._report.get('position_summaries',{})
        points=self._report.get('points',[])
        output=[]
        for point in points:
            name=point.get('name','')
            summary=summaries.get(name,{})
            output.append({'name':name,'x':point.get('x',0.5),
                'y':point.get('y',0.5),'z':point.get('z',0.5),
                'mean_dbfs':summary.get('mean_dbfs'),
                'samples':summary.get('samples',0)})
        return output

    @Property(str,notify=changed)
    def loadedSurveyName(self):
        return getattr(self,'_loaded_survey_name','')

    @Slot()
    def loadLatestSpatialSurvey(self):
        from pathlib import Path
        import json
        root=self._store.base
        paths=sorted(root.glob('room_survey_*.json'),
            key=lambda p:p.stat().st_mtime,reverse=True)
        for path in paths:
            try:
                report=json.loads(path.read_text())
                if not isinstance(report,dict) or not report.get('complete'):
                    continue
                points=report.get('points',[])
                summaries=report.get('position_summaries',{})
                if not isinstance(points,list) or not points or not isinstance(summaries,dict):
                    continue
                if any(not isinstance(p,dict) or p.get('name') not in summaries
                       or not all(k in p for k in ('x','y','z')) for p in points):
                    continue
                self._report=report
                self._loaded_survey_name=path.name
                self.logAdded.emit('Loaded spatial survey: '+str(path))
                self.changed.emit()
                return
            except (OSError,ValueError,TypeError) as exc:
                self.logAdded.emit('Skipped invalid survey '+path.name+': '+str(exc))
        self.logAdded.emit('No valid completed spatial survey found in '+str(root))

'''
s=s.replace(anchor,addition+anchor)
# notify QML after completion, not just via log
old='report=self._survey.report();self._report=report'
assert s.count(old)==1
s=s.replace(old,old+'\n                    self._loaded_survey_name=""')
p.write_text(s)
p=Path('qml/Main.qml');s=p.read_text()
old='''                            RoomVisualizer { id: resultImage; Layout.fillWidth: true; Layout.fillHeight: true
                                visible: backend.hasReconstruction && win.missionMode === "legacy"; results: backend.wallResults }'''
assert s.count(old)==1, 'Expected RoomVisualizer block not found'
new='''                            RoomVisualizer { id: resultImage; Layout.fillWidth: true; Layout.fillHeight: true
                                visible: backend.hasReconstruction && backend.spatialResults.length === 0; results: backend.wallResults }
                            SpatialResults {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                visible: backend.spatialResults.length > 0
                                measurements: backend.spatialResults
                                reportName: backend.loadedSurveyName
                            }'''
s=s.replace(old,new)
anchor='LabelText { text: "04  /  ACOUSTIC IMAGE"; color: win.cyan; font.bold: true }'
assert s.count(anchor)==1, 'Results header not found'
s=s.replace(anchor,anchor+'''
                                 ActionButton { text: "LOAD PREVIOUS SURVEY"; Layout.preferredWidth: 205; Layout.preferredHeight: 36
                                     onClicked: backend.loadLatestSpatialSurvey() }''')
# Existing list uses modelData; preserve legacy but allow dynamic spatial names
old='Repeater { model: ["center","north","east","south","west"]'
assert s.count(old)==1, 'Results list anchor not found'
s=s.replace(old,'Repeater { model: backend.spatialResults.length > 0 ? backend.spatialResults.map(function(p) { return p.name }) : ["center","north","east","south","west"]')
p.write_text(s)
print('[BCIEcho][PASS] Bridge and QML results pipeline patched')
PY
./.venv-qml/bin/python -m py_compile bciecho_qml/bridge.py
./.venv-qml/bin/python -m pytest -q tests/test_spatial_v213.py tests/test_survey_v21.py
sha256sum bciecho_qml/bridge.py qml/Main.qml qml/scenes/SpatialResults.qml | tee "logs/v215-spatial-$STAMP.sha256"
trap - ERR
echo "[BCIEcho][PASS] Spatial results patch installed. Backup: $BACKUP"
echo '[BCIEcho] Launch: ./.venv-qml/bin/python main_qml.py'