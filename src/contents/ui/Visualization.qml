/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.12 as Kirigami
import KRecorder 1.0

Item {
    id: visualization
    
    property int maxBarHeight
    property int animationIndex // which index rectangle is being expanded
    property var volumes: []
    property bool showLine
    
    Component.onCompleted: {
        AudioRecorder.prober.maxVolumes = width / 4;
        AudioPlayer.prober.maxVolumes = width / 4;
    }
    
    onWidthChanged: {
        AudioRecorder.prober.maxVolumes = width / 4;
        AudioPlayer.prober.maxVolumes = width / 4;
    }
    
    // central line
    Rectangle {
        visible: showLine
        id: centralLine
        width: parent.width
        height: 3
        anchors.verticalCenter: parent.verticalCenter
        color: "#e0e0e0"
    }
    
    ListView {
        id: list
        model: visualization.volumes
        orientation: Qt.Horizontal
        
        interactive: false
        anchors.verticalCenter: centralLine.verticalCenter
        height: maxBarHeight
        width: parent.width
        
        delegate: Item {
            width: Math.round(Kirigami.Units.gridUnit * 0.4)
            height: list.height
        
            Rectangle {
                color: Kirigami.Theme.disabledTextColor
                width: Math.round(Kirigami.Units.gridUnit * 0.12)
                radius: Math.round(width / 2)
                height: index === animationIndex ? 0 : 2 * maxBarHeight * modelData / 1000
                antialiasing: true
                anchors.verticalCenter: parent.verticalCenter

                Behavior on height {
                    SmoothedAnimation {
                        duration: 500
                    }
                }
            }
        }
    }
}
