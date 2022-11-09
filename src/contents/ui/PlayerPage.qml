/*
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

import "components"

Kirigami.Page {
    id: root
    
    property Recording recording
    
    title: recording.fileName
    
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
        
        Controls.Label {
            id: timeText
            Layout.alignment: Qt.AlignHCenter
            text: AudioPlayer.state === AudioPlayer.StoppedState ? "00:00:00" : Utils.formatTime(AudioPlayer.position)
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 3
            font.weight: Font.Light
        }           
        
        Visualization {
            Layout.fillWidth: true
            
            prober: AudioPlayer.prober
            showBarsFromMiddle: false
            showLine: false
            height: Kirigami.Units.gridUnit * 15
            maxBarHeight: Kirigami.Units.gridUnit * 5 * 2
            animationIndex: AudioPlayer.prober.animationIndex
        
            volumes: AudioPlayer.prober.volumesList
        }
        
        Controls.Slider {
            Layout.alignment: Qt.AlignHCenter
            from: 0
            to: AudioPlayer.duration
            value: AudioPlayer.position
            
            onMoved: AudioPlayer.setPosition(value)
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.largeSpacing
            Controls.ToolButton {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
                icon.name: AudioPlayer.state === AudioPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                onClicked: AudioPlayer.state === AudioPlayer.PlayingState ? AudioPlayer.pause() : AudioPlayer.play()
            }
            Controls.ToolButton {
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.5)
                implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.5)
                visible: AudioPlayer.state !== AudioPlayer.StoppedState
                icon.name: "media-playback-stop"
                onClicked: AudioPlayer.stop();
            }
        }
    }
}
