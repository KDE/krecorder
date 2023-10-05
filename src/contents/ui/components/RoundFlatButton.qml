/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Controls.AbstractButton {
    id: root
    hoverEnabled: true
    implicitWidth: Kirigami.Units.gridUnit * 3
    implicitHeight: Kirigami.Units.gridUnit * 3
    
    property color backgroundColor: Kirigami.Theme.highlightColor
    
    Controls.ToolTip.delay: Kirigami.Units.toolTipDelay
    Controls.ToolTip.timeout: 5000
    Controls.ToolTip.visible: Kirigami.Settings.tabletMode ? pressed : hovered
    Controls.ToolTip.text: text
    
    background: Rectangle {
        radius: width / 2
        color: root.pressed ? Qt.darker(root.backgroundColor, 1.3) : ((!Kirigami.Settings.tabletMode && root.hovered) ? Qt.darker(root.backgroundColor, 1.1) : root.backgroundColor)
    }
    
    Kirigami.Icon {
        anchors.centerIn: parent
        isMask: true
        source: root.icon.name
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false
        implicitWidth: Kirigami.Units.iconSizes.smallMedium
        implicitHeight: Kirigami.Units.iconSizes.smallMedium
    }
}
