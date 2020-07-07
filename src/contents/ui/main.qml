import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtMultimedia 5.12
import VoiceMemo 1.0
import QtQuick.Layouts 1.2
import QtQml 2.14

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Audio Recorder")

    width: 650
    height: 500
    
    globalDrawer: Kirigami.GlobalDrawer {
        actions: Kirigami.Action {
            text: i18n("Advanced Settings")
            icon.name: "settings-configure"
            onTriggered: pageStack.layers.push("qrc:/Settings.qml", {recorder: audioRecorder})
        }
    }

    AudioRecorder {
        id: audioRecorder
        property var lastRecording: {
            "recordingTime": "",
            "duration": "",
            "fileName": ""
        }

        // TODO
        // reasonable defaults for codec and container

        onDurationChanged: lastRecording["duration"] = duration
        onActualLocationChanged: lastRecording["fileName"] = audioRecorder.outputLocation.toString()
        onStatusChanged: {
            if (status == AudioRecorder.StartingStatus) {
                lastRecording["recordingTime"] = Date()
            }
        }

        onStateChanged: {
            if (state === AudioRecorder.StoppedState && outputLocation) {
                print(JSON.stringify(lastRecording))
                recordingModel.insertRecording(lastRecording)
            }
        }

        //onVolumesListChanged: console.log(volumesList)
    }
    
    RecordingModel {
        id: recordingModel
    }

    Audio {
        id: audioPlayer

        onSourceChanged: print(source)
    }

    pageStack.initialPage: RecordingListPage {}
}

