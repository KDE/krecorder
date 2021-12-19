/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

Loader {
    sourceComponent: !applicationWindow().isWidescreen ? mobileComponent : desktopComponent
    
    Component {
        id: desktopComponent
        Kirigami.Page {
            visible: false
            title: i18n("Record Audio")
            RecordingComponent {
                anchors.fill: parent
            }
        }
    }
    
    Component {
        id: mobileComponent
        Kirigami.OverlayDrawer {
            id: drawer
            height: appwindow.height * 0.8
            width: appwindow.width
            edge: Qt.BottomEdge
            parent: applicationWindow().overlay
            
            ColumnLayout {
                id: contents
                anchors.fill: parent
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
                    text: i18n("<b>New Recording</b>")
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: Kirigami.Units.largeSpacing * 2
                }
                
                RecordingComponent {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onOpenSheet: drawer.close()
                }
            }
        }
    }
}
