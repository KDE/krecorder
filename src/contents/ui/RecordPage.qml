/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

Kirigami.Page {
    
    title: i18n("Record Audio")
    property bool isStopped: AudioRecorder.state === AudioRecorder.StoppedState
    property bool isPaused: AudioRecorder.state === AudioRecorder.PausedState
    
    actions {
        main: Kirigami.Action {
            text: (isStopped || isPaused) ? i18n("Record") : i18n("Pause")
            icon.name: (isStopped || isPaused) ? "media-record" : "media-playback-pause"
            onTriggered: (isStopped || isPaused) ? AudioRecorder.record() : AudioRecorder.pause()
        }
        right: Kirigami.Action {
            text: i18n("Stop")
            icon.name: "media-playback-stop"
            onTriggered: {
                recordingName.text = RecordingModel.nextDefaultRecordingName();
                saveDialog.open();
                AudioRecorder.pause();
            }
            visible: !isStopped
        }
    }
    
    ColumnLayout {
        anchors.fill: parent

        Controls.Label {
            id: timeText
            Layout.alignment: Qt.AlignHCenter
            text: isStopped ? "00:00:00" : Utils.formatTime(AudioRecorder.duration)
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 3
        }            
        Visualization {
            Layout.fillWidth: true
            
            showLine: true
            height: Kirigami.Units.gridUnit * 15
            maxBarHeight: Kirigami.Units.gridUnit * 5
            animationIndex: AudioRecorder.prober.animationIndex
            
            volumes: AudioRecorder.prober.volumesList
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
                onClicked: {
                    AudioRecorder.reset()
                    saveDialog.close();
                }
            }
            
            Controls.Button {
                flat: false
                text: i18nc("@action:button", "Save")
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    AudioRecorder.setRecordingName(recordingName.text);
                    AudioRecorder.stop();
                    pageStack.layers.pop();
                    recordingName.text = "";
                    
                    saveDialog.close();
                }
            }
        }
        RowLayout {
            Controls.Label {
                Layout.alignment: Qt.AlignVCenter
                text: "Name"
            }
            Controls.TextField {
                id: recordingName
                placeholderText: i18n("Name (optional)")
            }
        }
    }
}
