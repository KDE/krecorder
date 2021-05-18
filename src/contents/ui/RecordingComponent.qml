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

Item {
    property bool isStopped: AudioRecorder.state === AudioRecorder.StoppedState
    property bool isPaused: AudioRecorder.state === AudioRecorder.PausedState

    signal openSheet()
    
    Connections {
        target: AudioRecorder
        function onError(error) {
            console.warn("Error on the recorder", error)
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
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 3
            font.weight: Font.Light
        }
        
        Item { Layout.fillHeight: true }
         
        Visualization {
            Layout.fillWidth: true
            
            prober: AudioRecorder.prober
            showBarsFromMiddle: true
            showLine: true
            height: Kirigami.Units.gridUnit * 10
            maxBarHeight: Kirigami.Units.gridUnit * 5 * 2
            animationIndex: AudioRecorder.prober.animationIndex
            
            volumes: AudioRecorder.prober.volumesList
        }
        
        Item { Layout.fillHeight: true }
        
        RowLayout {
            spacing: Kirigami.Units.largeSpacing * 2
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.gridUnit
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            Item { Layout.fillWidth: true }
            Controls.RoundButton {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
                
                text: (isStopped || isPaused) ? i18n("Record") : i18n("Pause")
                icon.name: (isStopped || isPaused) ? "media-record" : "media-playback-pause"
                display: Controls.AbstractButton.IconOnly
                
                onClicked: (isStopped || isPaused) ? AudioRecorder.record() : AudioRecorder.pause()
            }
            Controls.RoundButton {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 3)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 3)
                
                text: i18n("Stop")
                icon.name: "media-playback-stop"
                display: Controls.AbstractButton.IconOnly
                enabled: !isStopped
                
                onClicked: {
                    recordingName.text = RecordingModel.nextDefaultRecordingName();
                    openSheet();
                    saveDialog.open();
                    AudioRecorder.pause();
                }
            }
            Controls.RoundButton {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
                
                text: i18n("Settings")
                icon.name: "settings-configure"
                display: Controls.AbstractButton.IconOnly
                enabled: isStopped
                
                onClicked: {
                    openSheet();
                    settingsDialog.open();
                }
            }
            Item { Layout.fillWidth: true }
        }
    }

    Settings {
        id: settingsDialog
    }
    
    Kirigami.OverlaySheet {
        id: saveDialog
        
        header: Kirigami.Heading {
            level: 2
            text: i18n("Save recording")
        }
        
        footer: RowLayout {
            Item { Layout.fillWidth: true }
            
            Controls.Button {
                flat: false
                text: i18nc("@action:button", "Delete")
                icon.name: "delete"
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    AudioRecorder.reset()
                    saveDialog.close();
                }
            }
            
            Controls.Button {
                flat: false
                text: i18nc("@action:button", "Save")
                icon.name: "dialog-ok-apply"
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
            implicitWidth: Kirigami.Units.gridUnit * 12
            Controls.Label {
                id: nameLabel
                Layout.alignment: Qt.AlignVCenter
                text: i18n("Name:")
            }
            Controls.TextField {
                id: recordingName
                Layout.fillWidth: true
                placeholderText: i18n("Name (optional)")
            }
        }
    }
}
