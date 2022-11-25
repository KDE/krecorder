/*
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.20 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

import "components"

Kirigami.Page {
    id: root
    
    property Recording recording
    
    title: i18n("Player")
    
    onBackRequested: AudioPlayer.stop()
    
    property int yTranslate: 0
    property int mainOpacity: 0
    
    actions.contextualActions: [
        Kirigami.Action {
            visible: applicationWindow().isWidescreen
            iconName: "settings-configure"
            text: i18n("Settings")
            onTriggered: applicationWindow().openSettings();
        }
    ]
    
    background: Rectangle {
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, Kirigami.Settings.isMobile ? 1 : 0.9)
    }
    
    ColumnLayout {
        opacity: mainOpacity
        transform: Translate { y: yTranslate }
        anchors.fill: parent
        
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: Kirigami.Units.largeSpacing
            Layout.fillWidth: true
            
            Controls.Label {
                Layout.fillWidth: true
                text: recording.fileName
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
            
            Controls.Label {
                Layout.fillWidth: true
                text: i18n("Recorded on %1", recording.recordDate)
                opacity: 0.7
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }           
        }
        
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: Math.round(Kirigami.Units.gridUnit * 1.5)

            Item {
                Layout.fillWidth: true
            }
            
            // placeholder element for spacing, doesn't do anything
            Item {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
            }
            
            RoundFlatButton {
                implicitWidth: Kirigami.Units.gridUnit * 5
                implicitHeight: Kirigami.Units.gridUnit * 5
                text: AudioPlayer.state === AudioPlayer.PlayingState ? i18n("Pause") : i18n("Play")
                icon.name: AudioPlayer.state === AudioPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                onClicked: AudioPlayer.state === AudioPlayer.PlayingState ? AudioPlayer.pause() : AudioPlayer.play()
            }
            
            ToolTipToolButton {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
                opacity: AudioPlayer.state !== AudioPlayer.StoppedState ? 1 : 0
                icon.name: "media-playback-stop"
                text: i18n("Stop")
                onClicked: AudioPlayer.stop();
            }
            
            Item {
                Layout.fillWidth: true
            }
        }
        
        RowLayout {
            id: sliderBar
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.largeSpacing
            
            Controls.Label {
                id: elapsedLabel
                Layout.alignment: Qt.AlignVCenter
                text: AudioPlayer.state === AudioPlayer.StoppedState ? "0:00" : Utils.formatDuration(AudioPlayer.position)
                color: Kirigami.Theme.disabledTextColor
            }
            
            Controls.Slider {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: Math.min(root.width - Kirigami.Units.largeSpacing * 2 - elapsedLabel.width - durationLabel.width, root.width * 0.6)
                from: 0
                to: AudioPlayer.duration
                value: AudioPlayer.position
                
                Behavior on value {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }
                }
                
                onMoved: AudioPlayer.setPosition(value)
            }
            
            Controls.Label {
                id: durationLabel
                Layout.alignment: Qt.AlignVCenter
                text: recording.recordingLength
                color: Kirigami.Theme.disabledTextColor
            }
        }
    }
}
