// SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
// SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.12 as Kirigami
import KRecorder 1.0

Item {
    id: visualization
    
    property var prober
    
    property int maxBarHeight
    property int animationIndex // which index rectangle is being expanded
    property var volumes: []
    property bool showLine
    property bool showBarsFromMiddle
    
    property int reservedBarWidth: Math.round(Kirigami.Units.gridUnit * 0.4)
    
    // maximum volume to base off volume bar height
    // 1000 works for most audio formats, but some audio formats have higher average volumes
    property int maxVolumeData: 1000
    
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
            visualization.maxVolumeData = Math.max(visualization.maxVolumeData, volume);
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
                height: Math.max(Math.round(Kirigami.Units.gridUnit * 0.15), maxBarHeight * modelData / visualization.maxVolumeData)
                antialiasing: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
