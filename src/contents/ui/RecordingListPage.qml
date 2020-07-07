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
            icon.name: "microphone"
            onTriggered: pageStack.layers.push(recordPage)
        }
    }
    
    ListView {
        anchors.fill: parent
        model: recordingModel

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing
            
            icon.name: "microphone"
            text: i18n("No recordings yet, record your first!")
            visible: parent.count == 0
        }
        
        delegate: Kirigami.SwipeListItem {
            property Recording recording: recordingModel.at(index)
            
            onClicked: {
                audioPlayer.source = "file://" + recording.fileName
                audioPlayer.play()
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
                },
                Kirigami.Action {
                    text: i18n("Delete recording")
                    icon.name: "delete"
                    onTriggered: recordingModel.deleteRecording(index)
                }
            ]
        }
    }
}
