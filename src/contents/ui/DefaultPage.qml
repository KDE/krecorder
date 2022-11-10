/*
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

Kirigami.Page {
    title: ""
    
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
    
    Kirigami.PlaceholderMessage {
        opacity: mainOpacity
        transform: Translate { y: yTranslate }
        
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        icon.name: "microphone-sensitivity-medium"
        text: RecordingModel.count > 0 ? i18n("Play a recording, or record a new one") : ""
        type: Kirigami.PlaceholderMessage.Type.Informational
        
        helpfulAction: Kirigami.Action {
            icon.name: "audio-input-microphone-symbolic"
            text: i18n("Record a new recording")
            onTriggered: applicationWindow().openRecordScreen()
        }
    }
}
 
