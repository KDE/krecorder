/*
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls as Controls
import QtQuick.Layouts
import KRecorder

Kirigami.Page {
    title: ""
    visible: applicationWindow().isWidescreen

    actions: [
        Kirigami.Action {
            visible: applicationWindow().isWidescreen
            icon.name: "settings-configure"
            text: i18n("Settings")
            onTriggered: applicationWindow().openSettings();
        }
    ]

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        icon.name: "microphone-sensitivity-medium"
        text: RecordingModel.count > 0 ? i18n("Play a recording, or record a new one") : i18n("Record a new recording")
        type: Kirigami.PlaceholderMessage.Type.Informational
    }
}

