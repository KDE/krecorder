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
    flags: Qt.Dialog
    
    height: Kirigami.Units.gridUnit * 24
    width: Kirigami.Units.gridUnit * 35
    
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar;
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;
    
    pageStack.initialPage: Kirigami.ScrollablePage {
        globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
        SettingsComponent {
            // dialog: root
            // width: control.width
            onCloseRequested: dialog.close()
        }
    }
}
