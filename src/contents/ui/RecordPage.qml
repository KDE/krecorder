import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

Kirigami.Page {
    
    title: i18n("Record Audio")
    
    function isStopped() {
        return audioRecorder.state == AudioRecorder.StoppedState;
    }
    function isPaused() {
        return audioRecorder.state == AudioRecorder.PausedState;
    }
    
    actions {
        main: Kirigami.Action {
            text: (isStopped() || isPaused()) ? i18n("Record") : i18n("Pause")
            icon.name: (isStopped() || isPaused()) ? "media-record" : "media-playback-pause"
            onTriggered: (isStopped() || isPaused()) ? audioRecorder.record() : audioRecorder.pause()
        }
        right: Kirigami.Action {
            text: i18n("Stop")
            icon.name: "media-playback-stop"
            onTriggered: {
                saveDialog.open();
                audioRecorder.pause();
            }
            visible: !isStopped()
        }
    }
    
    Rectangle {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent

            Controls.Label {
                id: timeText
                Layout.alignment: Qt.AlignHCenter
                text: isStopped() ? "00:00:00" : Utils.formatTime(audioRecorder.duration)
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 3
            }            
            Visualization {
                Layout.fillWidth: true
                
                height: 200
                maxBarHeight: 70
                animationIndex: audioRecorder.animationIndex
                
                volumes: audioRecorder.volumesList
            }
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
                text: "Delete"
                Layout.alignment: Qt.AlignRight
                onClicked: audioRecorder.reset()
            }
            
            Controls.Button {
                flat: false
                text: "Save"
                Layout.alignment: Qt.AlignRight
                onClicked: {
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
