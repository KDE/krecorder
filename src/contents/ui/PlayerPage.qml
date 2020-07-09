import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

Kirigami.Page {
    
    property Recording recording
    
    title: recording.fileName
    
    onBackRequested: AudioPlayer.stop()
    
    actions {
        main: Kirigami.Action {
            text: AudioPlayer.state === AudioPlayer.PlayingState ? i18n("Pause") : i18n("Play")
            icon.name: AudioPlayer.state === AudioPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
            onTriggered: AudioPlayer.state === AudioPlayer.PlayingState ? AudioPlayer.pause() : AudioPlayer.play()
        }
        right: Kirigami.Action {
            visible: AudioPlayer.state !== AudioPlayer.StoppedState
            text: i18n("Stop")
            icon.name: "media-playback-stop"
            onTriggered: AudioPlayer.stop();
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        
        Controls.Label {
            id: timeText
            Layout.alignment: Qt.AlignHCenter
            text: AudioPlayer.state === AudioPlayer.StoppedState ? "00:00:00" : Utils.formatTime(AudioPlayer.position)
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 3
        }           
        
        Visualization {
            Layout.fillWidth: true
            
            showLine: false
            height: Kirigami.Units.gridUnit * 15
            maxBarHeight: Kirigami.Units.gridUnit * 5
            animationIndex: AudioPlayer.prober.animationIndex
        
            volumes: AudioPlayer.prober.volumesList
        }
        
        Controls.Slider {
            Layout.alignment: Qt.AlignHCenter
            from: 0
            to: AudioPlayer.duration
            value: AudioPlayer.position
            
            onMoved: AudioPlayer.setPosition(value)
        }
    }
}
