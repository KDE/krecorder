/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.12 as Kirigami
import KRecorder 1.0

Kirigami.ScrollablePage {
    title: i18n("Recordings")

    property Recording currentRecordingToEdit
    implicitWidth: appwindow.isWidescreen ? Kirigami.Units.gridUnit * 8 : undefined
    
    ListView {
        model: RecordingModel
        
        // prevent default highlight
        currentIndex: -1
        
        RecordPage {
            id: recordPage
            visible: false
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: Kirigami.Units.shortDuration }
        }
        remove: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: Kirigami.Units.shortDuration }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad}
        }
        
        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing
            
            icon.name: "audio-input-microphone-symbolic"
            text: i18n("No recordings yet, record your first!")
            visible: parent.count === 0
        }
        
        // record button
        RectangularGlow {
            anchors.fill: recordButton
            anchors.topMargin: 1
            cornerRadius: recordButton.radius * 2
            cached: true
            glowRadius: 4
            spread: 0.8
            color: Qt.darker(Kirigami.Theme.backgroundColor, 1.2)
        }
        Rectangle {
            id: recordButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Kirigami.Units.gridUnit
            implicitWidth: Kirigami.Units.gridUnit * 3
            implicitHeight: Kirigami.Units.gridUnit * 3
            radius: width / 2
            color: Kirigami.Theme.highlightColor
            
            Controls.AbstractButton {
                anchors.fill: parent
                onPressedChanged: {
                    if (pressed) {
                        parent.color = Qt.darker(Kirigami.Theme.highlightColor, 1.1)
                    } else {
                        parent.color = Kirigami.Theme.highlightColor
                    }
                }
                onClicked: {
                    pageStack.layers.push(recordPage)
                }
            }
            
            Kirigami.Icon {
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                Kirigami.Theme.inherit: false
                source: "audio-input-microphone-symbolic"
                anchors.centerIn: parent
                implicitWidth: Kirigami.Units.gridUnit * 2
                implicitHeight: Kirigami.Units.gridUnit * 2
            }
        }
        
        delegate: Kirigami.SwipeListItem {
            property Recording recording: modelData
            
            leftPadding: Kirigami.Units.largeSpacing * 2
            topPadding: Kirigami.Units.largeSpacing
            bottomPadding: Kirigami.Units.largeSpacing
            onClicked: appwindow.switchToRecording(recording)
            alwaysVisibleActions: false
            
            ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                
                Controls.Label {
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 1.1)
                    font.weight: Font.Medium
                    text: recording.fileName
                    color: (appwindow.currentRecording && appwindow.currentRecording.filePath === recording.filePath) ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor 
                }
                RowLayout {
                    Layout.bottomMargin: Kirigami.Units.smallSpacing
                    Controls.Label {
                        color: Kirigami.Theme.disabledTextColor
                        text: recording.recordDate
                    }
                    Item { Layout.fillWidth: true }
                    Controls.Label {
                        color: Kirigami.Theme.disabledTextColor
                        text: recording.recordingLength
                    }
                }
            }

            actions: [
                Kirigami.Action {
                    text: i18n("Edit")
                    icon.name: "entry-edit"
                    onTriggered: {
                        editDialogName.text = recording.fileName;
                        editDialogLocation.text = recording.filePath;
                        currentRecordingToEdit = recording;
                        
                        editNameDialog.open();
                    }
                },
                Kirigami.Action {
                    text: i18n("Delete recording")
                    icon.name: "delete"
                    onTriggered: {
                        deleteDialog.toDelete = recording;
                        deleteDialog.toDeleteIndex = index;
                        deleteDialog.open();
                    }
                }
            ]
        }
        
        Kirigami.OverlaySheet {
            id: deleteDialog
            property Recording toDelete: null
            property int toDeleteIndex: 0
            
            header: Kirigami.Heading {
                level: 2
                text: i18n("Delete") + " " + (deleteDialog.toDelete ? deleteDialog.toDelete.fileName : "")
            }
            footer: RowLayout {
                Item { Layout.fillWidth: true }
                
                Controls.Button {
                    flat: false
                    text: i18nc("@action:button", "Cancel")
                    icon.name: "dialog-cancel"
                    Layout.alignment: Qt.AlignRight
                    onClicked: deleteDialog.close();
                }
                
                Controls.Button {
                    flat: false
                    text: i18nc("@action:button", "Delete")
                    icon.name: "delete"

                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        if (deleteDialog.toDelete.filePath == appwindow.currentRecording.filePath) {
                            appwindow.switchToRecording(null);
                        }
                        RecordingModel.deleteRecording(deleteDialog.toDeleteIndex);
                        deleteDialog.close();
                    }
                }
            }
            Controls.Label {
                text: i18n("Are you sure you want to delete the recording %1? It will be permanently lost forever!", deleteDialog.toDelete ? deleteDialog.toDelete.fileName : "")
                wrapMode: Text.Wrap
            }
        }
        
        Kirigami.OverlaySheet {
            id: editNameDialog
            
            header: Kirigami.Heading {
                level: 2
                text: i18n("Editing") + " " + editDialogName.text
            }
            
            footer: RowLayout {
                Item { Layout.fillWidth: true }
                
                Controls.Button {
                    flat: false
                    text: i18nc("@action:button", "Cancel")
                    icon.name: "dialog-cancel"
                    Layout.alignment: Qt.AlignRight
                    onClicked: editNameDialog.close();
                }
                
                Controls.Button {
                    flat: false
                    text: i18nc("@action:button", "Done")
                    icon.name: "dialog-ok"

                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        currentRecordingToEdit.fileName = editDialogName.text;
                        editNameDialog.close();
                    }
                }
            }
            
            GridLayout {
                columns: 2
                rowSpacing: Kirigami.Units.largeSpacing * 2
                
                Kirigami.Heading {
                    text: i18n("Name:")
                    level: 4
                }
                Controls.TextField {
                    id: editDialogName
                    Layout.fillWidth: true
                }
                
                Kirigami.Heading {
                    text: i18n("Location:")
                    level: 4
                }
                Controls.Label {
                    id: editDialogLocation 
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
