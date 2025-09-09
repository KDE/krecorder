/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import KRecorder

import "components"

Kirigami.Page {
    id: root
    visible: false
    title: i18n("Record Audio")

    onBackRequested: {
        applicationWindow().pageStack.layers.pop();
        applicationWindow().switchToRecording(null);
        AudioRecorder.reset();
    }

    property bool isStopped: AudioRecorder.recorderState === AudioRecorder.StoppedState
    property bool isPaused: AudioRecorder.recorderState === AudioRecorder.PausedState

    onVisibleChanged: {
        // if page has been opened, and not in a recording session, start recording
        if (visible && (!isStopped && !isPaused)) {
            AudioRecorder.record();
        }
    }

    Connections {
        target: AudioRecorder
        function onErrorChanged() {
            console.warn("Error on the recorder", AudioRecorder.errorString)
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent

        Controls.Label {
            id: timeText
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Kirigami.Units.largeSpacing
            text: isStopped ? "00:00:00" : Utils.formatTime(AudioRecorder.duration)
            opacity: (root.isStopped || root.isPaused) ? 0.5 : 0.7
            font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 3)
            font.weight: Font.DemiBold
        }

        Item { Layout.fillHeight: true }

        // TODO visualization disabled until we port the model to Qt6
        // Visualization {
        //     Layout.fillWidth: true

        //     prober: AudioRecorder.prober
        //     showBarsFromMiddle: true
        //     showLine: true
        //     height: Kirigami.Units.gridUnit * 10
        //     maxBarHeight: Kirigami.Units.gridUnit * 5 * 2
        //     animationIndex: AudioRecorder.prober.animationIndex

        //     volumes: AudioRecorder.prober.volumesList
        // }

        // placeholder visualization for now
        Item {
            id: visualization
            height: Kirigami.Units.gridUnit * 10
            Layout.fillWidth: true

            Rectangle {
                color: Kirigami.Theme.highlightColor
                anchors.centerIn: parent
                height: Kirigami.Units.gridUnit * 12
                width: height
                radius: height / 2
                opacity: 0.5
                transformOrigin: Item.Center
                scale: recordingAnim.min

                NumberAnimation on scale {
                    id: recordingAnim
                    property real min: (9 / 12)
                    property real max: 1.0
                    to: max
                    running: !root.isStopped && !root.isPaused
                    easing.type: Easing.OutBack
                    duration: 2000
                    onRunningChanged: Easing.OutBack

                    onFinished: {
                        to = (to === min) ? max : min;
                        easing.type = (to === min) ? Easing.InBack : Easing.OutBack;
                        restart();
                    }
                }

                NumberAnimation on scale {
                    id: stopAnim
                    to: (7 / 12)
                    running: root.isStopped || root.isPaused
                    easing.type: Easing.OutExpo
                    duration: 2000
                }
            }

            RoundFlatButton {
                id: pauseButton
                anchors.centerIn: parent
                height: Kirigami.Units.gridUnit * 7
                width: height
                text: (!isStopped && isPaused) ? i18n("Continue") : i18n("Pause")

                onClicked: {
                    if (isPaused) {
                        AudioRecorder.record();
                    } else {
                        AudioRecorder.pause();
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

                Kirigami.Icon {
                    source: 'microphone-sensitivity-high'
                    implicitHeight: Kirigami.Units.iconSizes.huge
                    implicitWidth: Kirigami.Units.iconSizes.huge
                }
                Controls.Label {
                    visible: isStopped || isPaused
                    Layout.alignment: Qt.AlignCenter
                    text: i18n("Paused")
                    font.bold: true
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            spacing: Math.round(Kirigami.Units.gridUnit * 1.5)

            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.gridUnit
            Layout.topMargin: Kirigami.Units.largeSpacing

            Item { Layout.fillWidth: true }

            // moved pause button until we port the visualization to Qt6
            // ToolTipToolButton {
            //     implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
            //     implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
            //     text: (!isStopped && isPaused) ? i18n("Continue") : i18n("Pause")
            //     icon.name: (!isStopped && isPaused) ? "media-playback-start" : "media-playback-pause"

            //     onClicked: {
            //         if (isPaused) {
            //             AudioRecorder.record();
            //         } else {
            //             AudioRecorder.pause();
            //         }
            //     }
            // }

            RoundFlatButton {
                id: stopButton
                text: i18n("Save Recording")

                icon.name: "checkmark"

                onClicked: {
                    // pop record page off
                    applicationWindow().pageStack.layers.pop();
                    applicationWindow().switchToRecording(null);

                    // save recording
                    recordingName.text = RecordingModel.nextDefaultRecordingName();
                    saveDialog.open();
                    AudioRecorder.pause();
                }
            }

            ToolTipToolButton {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
                text: i18n("Delete")
                icon.name: "delete"

                onClicked: {
                    // pop record page off
                    applicationWindow().pageStack.layers.pop();
                    applicationWindow().switchToRecording(null);
                    AudioRecorder.reset();
                }
            }

            Item { Layout.fillWidth: true }
        }
    }

    FormCard.FormCardDialog {
        id: saveDialog

        closePolicy: Kirigami.Dialog.NoAutoClose
        standardButtons: Controls.Dialog.Discard | Controls.Dialog.Save

        title: i18n("Save recording")

        onAccepted: {
            AudioRecorder.setRecordingName(recordingName.text);
            AudioRecorder.stop();
            pageStack.layers.pop();
            recordingName.text = "";

            saveDialog.close();
        }

        onDiscarded: {
            AudioRecorder.reset()
            saveDialog.close();
        }

        FormCard.FormTextFieldDelegate {
            id: recordingName
            label: i18n("Name:")
            placeholderText: i18n("Name (optional)")
        }

        FormCard.FormTextDelegate {
            text: i18n("Storage Folder:")
            description: AudioRecorder.storageFolder
        }
    }
}
