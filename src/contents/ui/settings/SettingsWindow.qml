// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

// A settings window is used on desktop when the app is widescreen.
Kirigami.ApplicationWindow {
    id: root
    title: i18n("Settings")
    modality: Qt.ApplicationModal
    flags: Qt.Dialog

    height: Kirigami.Units.gridUnit * 25
    width: Kirigami.Units.gridUnit * 35

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar;
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;
    pageStack.columnView.columnResizeMode: Kirigami.ColumnView.SingleColumn

    // pop pages when not in use
    Connections {
        target: applicationWindow().pageStack
        function onCurrentIndexChanged() {
            // wait for animation to finish before popping pages
            closePageTimer.restart();
        }
    }

    Timer {
        id: closePageTimer
        interval: 300
        onTriggered: {
            let currentIndex = applicationWindow().pageStack.currentIndex;
            while (applicationWindow().pageStack.depth > (currentIndex + 1) && currentIndex >= 0) {
                applicationWindow().pageStack.pop();
            }
        }
    }

    pageStack.initialPage: Kirigami.ScrollablePage {
        topPadding: 0
        leftPadding: 0
        rightPadding: 0

        globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

        ColumnLayout {
            Kirigami.Separator { Layout.fillWidth: true }

            SettingsComponent {
                Layout.topMargin: Kirigami.Units.gridUnit
                Layout.fillWidth: true
                onCloseRequested: dialog.close()
            }
        }
    }
}
