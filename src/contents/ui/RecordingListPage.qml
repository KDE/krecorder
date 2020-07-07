import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import VoiceMemo 1.0

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
            onClicked: {
                audioPlayer.source = "file://" + model.fileName
                audioPlayer.play()
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                Controls.Label {
                    text: model.recordingTime
                }
                Controls.Label {
                    color: Kirigami.Theme.disabledTextColor
                    text: Utils.formatTime(model.duration)
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
                    onTriggered: recordingModel.deleteRecording(model.currentIndex)
                }
            ]
        }
    }
}
