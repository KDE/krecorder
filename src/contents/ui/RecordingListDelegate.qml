/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import KRecorder

import "components"

ListDelegate {
    id: root
    
    property Recording recording
    property bool editMode: false
    
    signal contextMenuRequested()
    signal editRequested()
    signal deleteRequested()
    signal exportRequested()
    
    leftPadding: Kirigami.Units.largeSpacing * 2
    rightPadding: Kirigami.Units.largeSpacing * 2
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    
    onClicked: applicationWindow().switchToRecording(recording)
    onRightClicked: root.contextMenuRequested()
    
    contentItem: RowLayout {
        spacing: 0
        
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.smallSpacing
            
            Controls.Label {
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.fillWidth: true
                font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 1.1)
                font.weight: Font.Medium
                text: recording.fileName
                wrapMode: Text.Wrap
                color: (applicationWindow().isWidescreen && applicationWindow().currentRecording && applicationWindow().currentRecording.filePath === recording.filePath) ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor 
            }
            
            RowLayout {
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                Controls.Label {
                    color: Kirigami.Theme.disabledTextColor
                    text: recording.recordDate
                }
                
                Item { Layout.fillWidth: true }
                
                Controls.Label {
                    visible: !root.editMode // don't show right aligned text when actions are shown
                    color: Kirigami.Theme.disabledTextColor
                    text: recording.recordingLength
                }
            }
        }
        
        ToolTipToolButton {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            icon.name: "document-save"
            text: i18n("Export to location")
            onClicked: root.exportRequested()
            visible: root.editMode
        }
        
        ToolTipToolButton {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            icon.name: "entry-edit"
            text: i18n("Rename")
            onClicked: root.editRequested()
            visible: root.editMode
        }
        
        ToolTipToolButton {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            icon.name: "delete"
            text: i18n("Delete")
            onClicked: root.deleteRequested()
            visible: root.editMode
        }
    }
}
