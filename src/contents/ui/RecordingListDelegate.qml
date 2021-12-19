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

Kirigami.SwipeListItem {
    id: root
    
    property Recording model
    
    signal editRequested()
    signal deleteRequested()
    
    leftPadding: Kirigami.Units.largeSpacing * 2
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    onClicked: applicationWindow().switchToRecording(model)
    alwaysVisibleActions: false
    
    ColumnLayout {
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

    actions: [
        Kirigami.Action {
            text: i18n("Edit")
            icon.name: "entry-edit"
            onTriggered: root.editRequested()
        },
        Kirigami.Action {
            text: i18n("Delete recording")
            icon.name: "delete"
            onTriggered: root.deleteRequested()
        }
    ]
}
