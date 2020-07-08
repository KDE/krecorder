import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0

Kirigami.Page {
    
    property Recording recording
    
    title: recording.fileName
    
    onBackRequested: audioPlayer.stop()
    
    actions {
        main: Kirigami.Action {
            text: audioPlayer.state === AudioPlayer.PlayingState ? i18n("Pause") : i18n("Play")
            icon.name: audioPlayer.state === AudioPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
            onTriggered: audioPlayer.state === AudioPlayer.PlayingState ? audioPlayer.pause() : audioPlayer.play()
        }
        right: Kirigami.Action {
            visible: audioPlayer.state !== AudioPlayer.StoppedState
            text: i18n("Stop")
            icon.name: "media-playback-stop"
            onTriggered: audioPlayer.stop();
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        
        Controls.Label {
            id: timeText
            Layout.alignment: Qt.AlignHCenter
            text: audioPlayer.state === AudioPlayer.StoppedState ? "00:00:00" : Utils.formatTime(audioPlayer.duration)
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 3
        }           
        
        Visualization {
            Layout.fillWidth: true
            
            showLine: false
            height: 200
            maxBarHeight: 70
            animationIndex: -1
        
            volumes: audioPlayer.prober().volumesList
        }
        
        Controls.Slider {
            Layout.alignment: Qt.AlignHCenter
            from: 0
            to: audioPlayer.duration
            value: audioPlayer.position
            
            onMoved: audioPlayer.setPosition(value)
        }
    }
}
