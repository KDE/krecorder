/*
 * Copyright 2021 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.12 as Kirigami

Control {
    id: root
    property bool showSeparator: false
    
    signal clicked()
    signal rightClicked()
    
    leftPadding: Kirigami.Units.largeSpacing
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    
    hoverEnabled: true
    background: Rectangle {
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, tapHandler.pressed ? 0.2 : root.hovered ? 0.1 : 0)
        
        TapHandler {
            id: tapHandler
            onTapped: root.clicked()
        }
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: root.rightClicked()
        }
        
        Kirigami.Separator {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: root.leftPadding
            anchors.rightMargin: root.rightPadding
            visible: root.showSeparator
            opacity: 0.5
        }
    }
}

