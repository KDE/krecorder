/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.3

import org.kde.kirigami 2.19 as Kirigami

import KRecorder 1.0

import "components"

Kirigami.ScrollablePage {
    id: root
    title: i18n("Recordings")

    property Recording currentRecordingToEdit
    property bool editMode
    
    onEditModeChanged: {
        editAction.checked = editMode;
    }
    
    implicitWidth: applicationWindow().isWidescreen ? Kirigami.Units.gridUnit * 8 : applicationWindow().width
    
    background: Rectangle {
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, Kirigami.Settings.isMobile ? 1 : 0.9)
    }
    
    actions.contextualActions: [
        Kirigami.Action {
            id: editAction
            iconName: "edit-entry"
            text: i18n("Edit")
            onTriggered: root.editMode = !root.editMode
            checkable: true
            visible: listView.count > 0
        },
        Kirigami.Action {
            visible: !applicationWindow().isWidescreen
            iconName: "settings-configure"
            text: i18n("Settings")
            onTriggered: applicationWindow().openSettings();
        },
        Kirigami.Action {
            visible: applicationWindow().isWidescreen
            icon.name: "audio-input-microphone-symbolic"
            text: i18n("Record")
            onTriggered: applicationWindow().openRecordScreen()
        }
    ]
    
    function editRecordingDialog(recording) {
        editDialogName.text = recording.fileName;
        editDialogLocation.text = recording.filePath;
        currentRecordingToEdit = recording;
        editNameDialog.open();
    }
    
    function removeRecordingDialog(recording, index) {
        deleteDialog.toDelete = recording;
        deleteDialog.toDeleteIndex = index;
        deleteDialog.open();
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
            
            icon.name: applicationWindow().isWidescreen ? "format-list-unordered" : "audio-input-microphone-symbolic"
            text: i18n("No recordings")
            visible: parent.count === 0
        }
        
        // record button
        FloatingActionButton {
            visible: !applicationWindow().isWidescreen
            icon.name: "audio-input-microphone-symbolic"
            onClicked: applicationWindow().openRecordScreen()
        }
        
        delegate: RecordingListDelegate {
            recording: model.recording
            width: listView.width
            editMode: root.editMode
            showSeparator: index != listView.count - 1
            
            onLongPressed: root.editMode = !root.editMode
            onEditRequested: root.editRecordingDialog(model.recording)
            onDeleteRequested: root.removeRecordingDialog(model.recording, index)
            onContextMenuRequested: {
                contextMenu.recording = model.recording;
                contextMenu.index = index;
                contextMenu.popup(this)
            }
            onExportRequested: saveFileDialog.openForRecording(model.recording)
        }
        
        FileDialog {
            id: saveFileDialog
            selectExisting: false
            selectFolder: false
            selectMultiple: false
            folder: shortcuts.music
                
            property Recording recording
            
            function openForRecording(recording) {
                title = i18n("Select a location to save recording %1", recording.fileName);
                defaultSuffix = recording.fileExtension;
                nameFilters = [`${recording.fileExtension} files (*.${recording.fileExtension})`];
                saveFileDialog.recording = recording;
                open();
            }
            
            onAccepted: {
                let prefixLessUrl = decodeURIComponent(fileUrl.toString().substring("file://".length));
                recording.createCopyOfFile(prefixLessUrl);
                applicationWindow().showPassiveNotification(i18n("Saved recording to %1", prefixLessUrl), "short");
            }
        }
        
        Controls.Menu {
            id: contextMenu
            modal: true
            Controls.Overlay.modal: MouseArea {}
            
            property Recording recording
            property int index
    
            Controls.MenuItem {
                text: i18n("Export to location")
                icon.name: "document-save"
                onTriggered: saveFileDialog.openForRecording(contextMenu.recording)
            }

            Controls.MenuItem {
                text: i18n("Edit")
                icon.name: "edit-entry"
                onTriggered: {
                    openDialogTimer.run = () => root.editRecordingDialog(contextMenu.recording);
                    openDialogTimer.restart();
                }
            }

            Controls.MenuItem {
                text: i18n("Delete")
                icon.name: "delete"
                onTriggered: {
                    openDialogTimer.run = () => root.removeRecordingDialog(contextMenu.recording, contextMenu.index);
                    openDialogTimer.restart();
                }
            }
        }
        
        // HACK: for some reason the dialog might close immediately if triggered from the context menu
        // open the dialog a little later to workaround this
        Timer {
            id: openDialogTimer
            interval: 50
            property var run: () => {}
            onTriggered: run()
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
                    onTriggered: {
                        deleteDialog.close();
                    }
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
            
            title: i18n("Rename %1", editDialogName.text)
            standardButtons: Kirigami.Dialog.Cancel | Kirigami.Dialog.Apply
            
            padding: Kirigami.Units.largeSpacing
            bottomPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
            preferredWidth: Kirigami.Units.gridUnit * 20
            
            onApplied: {
                 currentRecordingToEdit.fileName = editDialogName.text;
                 editNameDialog.close();
            }
            
            Kirigami.FormLayout {
                Controls.TextField {
                    id: editDialogName
                    Kirigami.FormData.label: i18n("Name:")
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
