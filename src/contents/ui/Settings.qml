/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.8 as Kirigami
import KRecorder 1.0

Loader {
    sourceComponent: appwindow.isWidescreen ? widescreenComponent : narrowComponent
    
    function open() {
        item.open();
    }
    
    Component {
        id: widescreenComponent
        Kirigami.OverlaySheet {
            parent: parent.overlay
            header: Kirigami.Heading {
                level: 2
                text: i18n("Settings")
            }
            
            contentItem: SettingsComponent {}
        }
    }
    
    Component {
        id: narrowComponent
        Kirigami.OverlayDrawer {
            id: drawer
            height: Math.max(appwindow.height * 0.4, contents.height + Kirigami.Units.largeSpacing * 2)
            width: appwindow.width
            edge: Qt.BottomEdge
            z: -1
            
            Behavior on height {
                NumberAnimation { duration: Kirigami.Units.shortDuration }
            }
            
            ColumnLayout {
                id: contents
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0
                
                Kirigami.Icon {
                    Layout.margins: Kirigami.Units.smallSpacing
                    source: "arrow-down"
                    implicitWidth: Kirigami.Units.gridUnit
                    implicitHeight: Kirigami.Units.gridUnit
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Kirigami.Heading {
                    level: 3
                    text: i18n("<b>Settings</b>")
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: Kirigami.Units.largeSpacing * 2
                }
                
                SettingsComponent {
                    Layout.fillWidth: true
                    Layout.bottomMargin: Kirigami.Units.largeSpacing
                }
            }
        }
    }
}
