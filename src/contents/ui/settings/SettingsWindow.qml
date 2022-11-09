// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.0
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.19 as Kirigami
import KRecorder 1.0

Kirigami.ApplicationWindow {
    id: root
    title: i18n("Settings")
    flags: Qt.Dialog | Qt.WindowStaysOnTopHint
    
    height: Kirigami.Units.gridUnit * 24
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