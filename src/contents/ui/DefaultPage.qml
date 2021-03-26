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

    Kirigami.PlaceholderMessage {
        opacity: mainOpacity
        transform: Translate { y: yTranslate }
        
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        icon.name: "microphone-sensitivity-medium"
        text: i18n("Click on a recording to play it, or record a new one")
    }
}
 
