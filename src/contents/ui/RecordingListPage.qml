/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

Kirigami.ScrollablePage {
    title: i18n("Recordings")
    
    RecordPage {
        id: recordPage
        visible: false
    }
    
    actions {
        main: Kirigami.Action {
            text: i18n("Record")
            icon.name: "audio-input-microphone-symbolic"
            onTriggered: pageStack.layers.push(recordPage)
        }
    }
    
    property Recording currentRecordingToEdit
    
    ListView {
        anchors.fill: parent
        model: RecordingModel

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing
            
            icon.name: "audio-input-microphone-symbolic"
            text: i18n("No recordings yet, record your first!")
            visible: parent.count === 0
        }
        
        delegate: Kirigami.SwipeListItem {
            property Recording recording: modelData
            
            onClicked: {
                AudioPlayer.setVolume(100);
                AudioPlayer.setMediaPath(recording.filePath)
                AudioPlayer.play()
                
                pageStack.layers.push("qrc:/PlayerPage.qml", {recording: recording});
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                Controls.Label {
                    text: recording.fileName
                }
                Controls.Label {
                    color: Kirigami.Theme.disabledTextColor
                    text: recording.recordingLength
                }
                Controls.Label {
                    color: Kirigami.Theme.disabledTextColor
                    text: recording.recordDate
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
                    onTriggered: RecordingModel.deleteRecording(index)
                }
            ]
        }
    }
    
    Kirigami.OverlaySheet {
        id: editNameDialog
        
        function updateFileName(name) {
            recording.fileName = name;
        }
        
        footer: RowLayout {
            Item {
                Layout.fillWidth: true
            }
            
            Controls.Button {
                flat: false
                text: i18nc("@action:button", "Cancel")
                Layout.alignment: Qt.AlignRight
                onClicked: editNameDialog.close();
            }
            
            Controls.Button {
                flat: false
                text: i18nc("@action:button", "Done")

                Layout.alignment: Qt.AlignRight
                onClicked: {
                    currentRecordingToEdit.fileName = editDialogName.text;
                    editNameDialog.close();
                }
            }
        }
        
        GridLayout {
            columns: 2
            rowSpacing: Kirigami.Units.largeSpacing
            
            Kirigami.Heading {
                text: i18n("Name")
                level: 4
            }
            Controls.TextField {
                id: editDialogName
            }
            
            Kirigami.Heading {
                text: i18n("Location")
                level: 4
            }
            Controls.Label {
                id: editDialogLocation 
            }
        }
    }
}
