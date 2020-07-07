import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import VoiceMemo 1.0

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
        color: Kirigami.Theme.hoverColor
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.bottomMargin: 100
            spacing: 0

            Visualization {
                Layout.fillWidth: true
                height: 500

                volumes: audioRecorder.volumesList
            }

            GradientBar {
                Layout.alignment: Qt.AlignHCenter
            }

            Kirigami.Heading {
                id: timeText
                Layout.alignment: Qt.AlignHCenter
                text: Utils.formatTime(audioRecorder.duration)
            }

            GradientBar {
                Layout.alignment: Qt.AlignHCenter
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
            }
            Controls.Button {
                flat: false
                text: "Save"
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    audioRecorder.stop();
                    pageStack.layers.pop();
                }
            }
        }
        
        Controls.TextField {
            id: recordingName
            placeholderText: "Name"
        }
    }
}
