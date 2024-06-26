// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import KRecorder

Item {
    id: visualization

    property var prober

    property int maxBarHeight
    property int animationIndex // which index rectangle is being expanded
    property var volumes: []
    property bool showLine
    property bool showBarsFromMiddle

    property int reservedBarWidth: Math.round(Kirigami.Units.gridUnit * 0.4)

    property var simpleAudioFormatSetting: SettingsModel.simpleAudioFormat

    // maximum volume to base off volume bar height
    property int maxVolumeData: 1000

    // TODO: We need a more sophisticated algorithm to create the visualizer bars (probably using FFT)
    // currently we just see how much data is in a sample, which is really random and doesn't deal with spikes very well

    function processVolume(volume) {
        // vorbis for some reason has its volume data upside-down
        if (simpleAudioFormatSetting == SettingsModel.VORBIS) {
            volume = Math.max(0, 17000 - volume);
        }
        return volume;
    }

    Component.onCompleted: {
        visualization.prober.maxVolumes = (showBarsFromMiddle ? width / 2 : width) / reservedBarWidth;
    }
    onWidthChanged: {
        visualization.prober.maxVolumes = (showBarsFromMiddle ? width / 2 : width) / reservedBarWidth;
    }

    Connections {
        target: visualization.prober
        function onVolumesListCleared() {
            visualization.maxVolumeData = 1000; // reset max
        }
        function onVolumesListAdded(volume) {
            visualization.maxVolumeData = Math.max(visualization.maxVolumeData, processVolume(volume));
        }
    }

    // central line
    Rectangle {
        id: verticalBar
        visible: showLine
        z: 1
        anchors.top: list.top
        anchors.bottom: list.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.round(Kirigami.Units.gridUnit * 0.1)
        color: Kirigami.Theme.negativeTextColor
    }

    ListView {
        id: list
        model: visualization.volumes
        orientation: Qt.Horizontal

        interactive: false
        height: maxBarHeight
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: showBarsFromMiddle ? Math.max(0, parent.width / 2 - list.count * reservedBarWidth) : 0 // gradually expand list
        anchors.right: showBarsFromMiddle ? verticalBar.left : parent.right
        spacing: 0

        delegate: Item {
            width: reservedBarWidth
            height: list.height

            Rectangle {
                color: Kirigami.Theme.disabledTextColor
                width: Math.round(Kirigami.Units.gridUnit * 0.12)
                radius: Math.round(width / 2)
                height: Math.max(Math.round(Kirigami.Units.gridUnit * 0.15), maxBarHeight * processVolume(modelData) / visualization.maxVolumeData)
                antialiasing: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
