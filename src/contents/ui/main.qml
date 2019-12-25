import QtQuick 2.12
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtMultimedia 5.12
import VoiceMemo 1.0
import QtQuick.Layouts 1.2
import QtQml 2.14

Kirigami.ApplicationWindow {
    id: root

    title: i18n("voicememo")

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

            // Child 0
            Controls.ScrollView {
                ListView {
                    Controls.Label {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: i18n("No recordings yet, record your first!")
                    }

                    anchors.fill: parent
                    model: RecordingModel {id: recordingModel}

                    delegate: Kirigami.SwipeListItem {
                        ColumnLayout {
                            Layout.fillWidth: true
                            Controls.Label {
                                text: model.recordingTime
                            }
                            Controls.Label {
                                color: Kirigami.Theme.disabledTextColor
                                text: Utils.formatTime(model.duration)
                            }
                        }

                        actions: [
                            Kirigami.Action {
                                text: i18n("Delete recording")
                                icon.name: "list-remove"
                                onTriggered: recordingModel.deleteRecording(model.currentIndex)
                            }
                        ]
                    }
                }
            }

            // Child 1
            Rectangle {
                color: Kirigami.Theme.hoverColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.bottomMargin: 100
                    spacing: 0

                    Visualization {
                        Layout.fillWidth: true
                        height: 500

                        Timer {
                            interval: 100
                            running: true
                            repeat: true
                            onTriggered: {
                                parent.value1 = Utils.randomNumber()
                                parent.value2 = Utils.randomNumber()
                                parent.value3 = Utils.randomNumber()
                                parent.value4 = Utils.randomNumber()
                                parent.value5 = Utils.randomNumber()
                            }
                        }
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
        }
    }
}

