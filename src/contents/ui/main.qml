import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtMultimedia 5.12
import KRecorder 1.0
import QtQuick.Layouts 1.2
import QtQml 2.14

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Audio Recorder")

    width: 650
    height: 500
    
//     pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
    
    globalDrawer: Kirigami.GlobalDrawer {
        actions: Kirigami.Action {
            text: i18n("Advanced Settings")
            icon.name: "settings-configure"
            onTriggered: pageStack.layers.push("qrc:/Settings.qml", {recorder: audioRecorder})
        }
    }

    Audio {
        id: audioPlayer

        onSourceChanged: print(source)
    }

    AudioRecorder {
        id: audioRecorder
        //onVolumesListChanged: console.log(volumesList)
    }
    
    pageStack.initialPage: RecordingListPage {}
}

