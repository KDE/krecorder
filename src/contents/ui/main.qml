import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtMultimedia 5.12
import VoiceMemo 1.0
import QtQuick.Layouts 1.2

Kirigami.ApplicationWindow {
    id: root

    title: i18n("voicememo")

    globalDrawer: Kirigami.GlobalDrawer {
        actions: Kirigami.Action {
            text: i18n("Settings")
            icon.name: "settings-configure"
        }
    }

    AudioRecorder {
        id: audioRecorder
        onStateChanged: console.log("state changed", state)
        onStatusChanged: console.log("Status chaged", status)
    }

    pageStack.initialPage: Kirigami.Page {
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        title: i18n("Audio Recorder")
        actions {
            main: Kirigami.Action {
                text: audioRecorder.status === AudioRecorder.RecordingStatus ? i18n("Stop") : i18n("Start")
                icon.name: audioRecorder.status === AudioRecorder.RecordingStatus ? "media-playback-stop" : "media-record"
                onTriggered: audioRecorder.status === AudioRecorder.RecordingStatus ? audioRecorder.stop() : audioRecorder.record()
            }
        }

        Controls.SwipeView {
            anchors.fill: parent
            interactive: false
            currentIndex: audioRecorder.status === AudioRecorder.RecordingStatus ? 1 : 0
            Controls.ScrollView {
                ListView {
                    anchors.fill: parent
                    model: ListModel {
                        ListElement {
                            name: "Aufnahme 1"
                        }
                        ListElement {
                            name: "Aufnahme 3"
                        }
                    }

                    delegate: Kirigami.BasicListItem {
                        text: name
                    }
                }
            }
            Rectangle {
                color: "lightblue"

                ColumnLayout {
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 500
                        height: 500
                    }
                    Controls.Label {
                        text: audioRecorder.duration
                    }
                }
            }
        }
    }
}

