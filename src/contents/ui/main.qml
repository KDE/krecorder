/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtMultimedia 5.12
import KRecorder 1.0
import QtQuick.Layouts 1.2
import QtQml 2.14

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Recorder")

    width: 650
    height: 500
    
    globalDrawer: Kirigami.GlobalDrawer {
        actions: Kirigami.Action {
            text: i18n("Settings")
            icon.name: "settings-configure"
            onTriggered: pageStack.layers.push("qrc:/Settings.qml", {recorder: AudioRecorder})
        }
    }
    
    pageStack.initialPage: RecordingListPage {}
}

