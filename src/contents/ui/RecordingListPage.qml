/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.2

import org.kde.kirigami 2.19 as Kirigami

import KRecorder 1.0

Kirigami.ScrollablePage {
    title: i18n("Recordings")

    property Recording currentRecordingToEdit
    implicitWidth: applicationWindow().isWidescreen ? Kirigami.Units.gridUnit * 8 : applicationWindow().width
    
    mainAction: Kirigami.Action {
        iconName: "settings-configure"
        text: i18n("Settings")
        onTriggered: {
            settingsDialog.open();
        }
    }
    
    ListView {
        id: listView
        model: RecordingModel
        
        // show animation
        property int yTranslate: 0
        transform: Translate { y: listView.yTranslate }
        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: Kirigami.Units.longDuration * 2
            easing.type: Easing.InOutQuad
            running: true
        }
        NumberAnimation {
            from: Kirigami.Units.gridUnit * 3
            to: 0
            duration: Kirigami.Units.longDuration * 3
            easing.type: Easing.OutQuint
            property: "yTranslate"
            target: listView
            running: true
        }
        
        // prevent default highlight
        currentIndex: -1

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
            text: applicationWindow().isWidescreen ? i18n("No recordings") : i18n("No recordings yet, record your first!")
            visible: parent.count === 0
        }
        
        // record component and button
        Record {
            id: recordComponent
        }
        
        FloatingActionButton {
            anchors.fill: parent
            iconName: "audio-input-microphone-symbolic"
            onClicked: {
                if (!applicationWindow().isWidescreen) {
                    recordComponent.item.open();
                } else {
                    pageStack.layers.push(recordComponent.item);
                }
            }
        }
        
        delegate: RecordingListDelegate {
            model: recording
            
            onEditRequested: {
                editDialogName.text = recording.fileName;
                editDialogLocation.text = recording.filePath;
                currentRecordingToEdit = recording;
                editNameDialog.open();
            }
            onDeleteRequested: {
                deleteDialog.toDelete = recording;
                deleteDialog.toDeleteIndex = index;
                deleteDialog.open();
            }
        }
        
        Kirigami.PromptDialog {
            id: deleteDialog
            standardButtons: Kirigami.Dialog.NoButton
            
            property Recording toDelete: null
            property int toDeleteIndex: 0
            
            title: i18n("Delete %1", deleteDialog.toDelete ? deleteDialog.toDelete.fileName : "")
            subtitle: i18n("Are you sure you want to delete the recording %1?<br/>It will be <b>permanently lost</b> forever!", deleteDialog.toDelete ? deleteDialog.toDelete.fileName : "")
            
            customFooterActions: [
                Kirigami.Action {
                    text: i18nc("@action:button", "Cancel")
                    iconName: "dialog-cancel"
                    onTriggered: deleteDialog.close();
                },
                Kirigami.Action {
                    text: i18nc("@action:button", "Delete")
                    iconName: "delete"
                    onTriggered: {
                        if (applicationWindow().currentRecording && deleteDialog.toDelete.filePath == applicationWindow().currentRecording.filePath) {
                            applicationWindow().switchToRecording(null);
                        }
                        RecordingModel.deleteRecording(deleteDialog.toDeleteIndex);
                        deleteDialog.close();
                    }
                }
            ]
        }
        
        Kirigami.Dialog {
            id: editNameDialog
            
            title: i18n("Editing %1", editDialogName.text)
            standardButtons: Kirigami.Dialog.Cancel | Kirigami.Dialog.Apply
            
            padding: Kirigami.Units.largeSpacing
            bottomPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
            preferredWidth: Kirigami.Units.gridUnit * 20
            
            onRejected: editNameDialog.close();
            onApplied: {
                 currentRecordingToEdit.fileName = editDialogName.text;
                 editNameDialog.close();
            }
            
            Kirigami.FormLayout {
                Controls.TextField {
                    id: editDialogName
                    Kirigami.FormData.label: i18n("Audio Input:")
                    Layout.fillWidth: true
                }
                
                Controls.Label {
                    id: editDialogLocation 
                    Kirigami.FormData.label: i18n("Location:")
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
