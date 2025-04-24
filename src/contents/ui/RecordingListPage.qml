/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2022 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtCore
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.kirigamiaddons.components as Components

import KRecorder

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

    actions: [
        Kirigami.Action {
            id: editAction
            icon.name: "edit-entry"
            text: i18n("Edit")
            onTriggered: root.editMode = !root.editMode
            checkable: true
            visible: listView.count > 0
        },
        Kirigami.Action {
            visible: !applicationWindow().isWidescreen
            icon.name: "settings-configure"
            text: i18n("Settings")
            onTriggered: applicationWindow().openSettings();
        },
        Kirigami.Action {
            visible: applicationWindow().isWidescreen
            icon.name: "microphone-sensitivity-high"
            text: i18n("Record")
            onTriggered: applicationWindow().openRecordScreen()
        }
    ]

    function editRecordingDialog(recording) {
        editDialogName.text = recording.fileName;
        editDialogLocation.description = recording.filePath;
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
        property real yTranslate: 0
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

            icon.name: applicationWindow().isWidescreen ? "format-list-unordered" : "microphone-sensitivity-high"
            text: i18n("No recordings")
            visible: parent.count === 0
        }

        // record button
        FloatingActionButton {
            visible: !applicationWindow().isWidescreen
            icon.name: 'microphone-sensitivity-high'
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
            fileMode: FileDialog.SaveFile
            currentFolder: StandardPaths.writableLocation(StandardPaths.MusicLocation)

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

        Components.MessageDialog {
            id: deleteDialog

            property Recording toDelete: null
            property int toDeleteIndex: 0

            standardButtons: Controls.Dialog.Cancel | Controls.Dialog.Ok
            dialogType: Components.MessageDialog.Warning

            Component.onCompleted: {
                const deleteButton = standardButton(Controls.Dialog.Ok);
                deleteButton.text = i18nc("@action:button", "Delete");
                deleteButton.icon.name = "delete-symbolic";
            }

            title: i18n("Delete %1", deleteDialog.toDelete ? deleteDialog.toDelete.fileName : "")

            onAccepted: {
                if (applicationWindow().currentRecording && deleteDialog.toDelete.filePath == applicationWindow().currentRecording.filePath) {
                    applicationWindow().switchToRecording(null);
                }
                RecordingModel.deleteRecording(deleteDialog.toDeleteIndex);
                deleteDialog.close();
            }

            onRejected: deleteDialog.close()

            Controls.Label {
                text: i18n("Are you sure you want to delete the recording %1?<br/>It will be <b>permanently lost</b> forever!", deleteDialog.toDelete ? deleteDialog.toDelete.fileName : "")
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }

        FormCard.FormCardDialog {
            id: editNameDialog

            title: i18n("Rename %1", editDialogName.text)
            standardButtons: Controls.Dialog.Cancel | Controls.Dialog.Apply

            onApplied: {
                 currentRecordingToEdit.fileName = editDialogName.text;
                 editNameDialog.close();
            }

            onRejected: editNameDialog.close();

            FormCard.FormTextFieldDelegate {
                id: editDialogName
                label: i18n("Name:")
            }

            FormCard.FormTextDelegate {
                id: editDialogLocation
                text: i18n("Location:")
            }
        }
    }
}
