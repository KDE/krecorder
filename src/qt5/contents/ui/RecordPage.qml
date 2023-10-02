/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2

import org.kde.kirigami 2.19 as Kirigami

import KRecorder 1.0

import "components"

Kirigami.Page {
    id: root
    visible: false
    title: i18n("Record Audio")
    
    property bool isStopped: AudioRecorder.state === AudioRecorder.StoppedState
    property bool isPaused: AudioRecorder.state === AudioRecorder.PausedState
    
    onVisibleChanged: {
        // if page has been opened, and not in a recording session, start recording
        if (visible && (!isStopped && !isPaused)) {
            AudioRecorder.record();
        }
    }
    
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
            opacity: 0.7
            font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 3)
            font.weight: Font.DemiBold
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
            spacing: Math.round(Kirigami.Units.gridUnit * 1.5)
            
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.gridUnit
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            Item { Layout.fillWidth: true }
            
            ToolTipToolButton {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
                text: (!isStopped && isPaused) ? i18n("Continue") : i18n("Pause")
                icon.name: (!isStopped && isPaused) ? "media-playback-start" : "media-playback-pause"
                
                onClicked: {
                    if (isPaused) {
                        AudioRecorder.record();
                    } else {
                        AudioRecorder.pause();
                    }
                }
            }
            
            RoundFlatButton {
                id: stopButton
                text: i18n("Stop Recording")
                
                icon.name: "media-playback-stop"
                
                onClicked: {
                    // pop record page off
                    applicationWindow().pageStack.layers.pop();
                    
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
                    AudioRecorder.reset();
                }
            }
            
            Item { Layout.fillWidth: true }
        }
    }
    
    Kirigami.Dialog {
        id: saveDialog
        standardButtons: Kirigami.Dialog.NoButton
        padding: Kirigami.Units.largeSpacing
        bottomPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
        
        title: i18n("Save recording")
        
        customFooterActions: [
            Kirigami.Action {
                text: i18n("Save")
                iconName: "document-save"
                onTriggered: {
                    AudioRecorder.setRecordingName(recordingName.text);
                    AudioRecorder.stop();
                    pageStack.layers.pop();
                    recordingName.text = "";
                            
                    saveDialog.close();
                }
            },
            Kirigami.Action {
                text: i18n("Discard")
                iconName: "delete"
                onTriggered: {
                    AudioRecorder.reset()
                    saveDialog.close();
                }
            }
        ]
        
        Kirigami.FormLayout {
            implicitWidth: Kirigami.Units.gridUnit * 20
            
            Controls.TextField {
                id: recordingName
                Kirigami.FormData.label: i18n("Name:")
                placeholderText: i18n("Name (optional)")
            }
            
            Controls.Label {
                Kirigami.FormData.label: i18n("Storage Folder:")
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: AudioRecorder.storageFolder
            }
        }
    }
}
