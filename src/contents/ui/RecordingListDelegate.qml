/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.2

import org.kde.kirigami 2.19 as Kirigami

import KRecorder 1.0

import "components"

ListDelegate {
    id: root
    
    property Recording model
    property bool editMode: false
    
    signal contextMenuRequested()
    signal editRequested()
    signal deleteRequested()
    
    leftPadding: Kirigami.Units.largeSpacing * 2
    rightPadding: Kirigami.Units.largeSpacing * 2
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    
    onClicked: applicationWindow().switchToRecording(model)
    onRightClicked: root.contextMenuRequested()
    
    contentItem: RowLayout {
        spacing: 0
        
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.smallSpacing
            
            Controls.Label {
                Layout.topMargin: Kirigami.Units.smallSpacing
                font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 1.1)
                font.weight: Font.Medium
                text: model.fileName
                color: (applicationWindow().isWidescreen && applicationWindow().currentRecording && applicationWindow().currentRecording.filePath === model.filePath) ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor 
            }
            
            RowLayout {
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                Controls.Label {
                    color: Kirigami.Theme.disabledTextColor
                    text: model.recordDate
                }
                Item { Layout.fillWidth: true }
                Controls.Label {
                    color: Kirigami.Theme.disabledTextColor
                    text: model.recordingLength
                }
            }
        }
        
        Controls.ToolButton {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            icon.name: "entry-edit"
            text: i18n("Edit")
            onClicked: root.editRequested()
            visible: root.editMode
            display: Controls.AbstractButton.IconOnly
            
            Controls.ToolTip.delay: Kirigami.Units.toolTipDelay
            Controls.ToolTip.timeout: 5000
            Controls.ToolTip.visible: Kirigami.Settings.tabletMode ? pressed : hovered
            Controls.ToolTip.text: text
        }
        
        Controls.ToolButton {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            icon.name: "delete"
            text: i18n("Delete")
            onClicked: root.deleteRequested()
            visible: root.editMode
            display: Controls.AbstractButton.IconOnly
            
            Controls.ToolTip.delay: Kirigami.Units.toolTipDelay
            Controls.ToolTip.timeout: 5000
            Controls.ToolTip.visible: Kirigami.Settings.tabletMode ? pressed : hovered
            Controls.ToolTip.text: text
        }
    }
}
