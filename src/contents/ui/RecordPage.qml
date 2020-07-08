import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

Kirigami.Page {
    
    title: i18n("Record Audio")
    property bool isStopped: audioRecorder.state === AudioRecorder.StoppedState
    property bool isPaused: audioRecorder.state === AudioRecorder.PausedState
    
    actions {
        main: Kirigami.Action {
            text: (isStopped || isPaused) ? i18n("Record") : i18n("Pause")
            icon.name: (isStopped || isPaused) ? "media-record" : "media-playback-pause"
            onTriggered: (isStopped || isPaused) ? audioRecorder.record() : audioRecorder.pause()
        }
        right: Kirigami.Action {
            text: i18n("Stop")
            icon.name: "media-playback-stop"
            onTriggered: {
                saveDialog.open();
                audioRecorder.pause();
            }
            visible: !isStopped
        }
    }
    
        ColumnLayout {
            anchors.fill: parent

            Controls.Label {
                id: timeText
                Layout.alignment: Qt.AlignHCenter
                text: isStopped ? "00:00:00" : Utils.formatTime(audioRecorder.duration)
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 3
            }            
            Visualization {
                Layout.fillWidth: true
                
                showLine: true
                height: Kirigami.Units.gridUnit * 15
                maxBarHeight: Kirigami.Units.gridUnit * 5
                animationIndex: audioRecorder.prober.animationIndex
                
                volumes: audioRecorder.prober.volumesList
            }
        }
    
    Kirigami.OverlaySheet {
        id: saveDialog
        
        header: Kirigami.Heading {
            text: "Save recording"
        }
        
        footer: RowLayout {
            Item {
                Layout.fillWidth: true
            }
            
            Controls.Button {
                flat: false
                text: i18nc("@action:button", "Delete")
                Layout.alignment: Qt.AlignRight
                onClicked: audioRecorder.reset()
            }
            
            Controls.Button {
                flat: false
                text: i18nc("@action:button", "Save")
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    console.log(audioRecorder.actualLocation); // TODO
                    
                    audioRecorder.setRecordingName(recordingName.text);
                    audioRecorder.stop();
                    pageStack.layers.pop();
                    recordingName.text = "";
                }
            }
        }
        
        Controls.TextField {
            id: recordingName
            placeholderText: i18n("Name (optional)")
        }
    }
}
