import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2 as Controls

// import org.kde.quickcharts 1.0 as Charts

Item {
    id: visualization
    height: 500
    property var volumes: []
    
    Component.onCompleted: {
        audioRecorder.setMaxVolumes(width / 4);
    }
    
    onWidthChanged: {
        audioRecorder.setMaxVolumes(width / 4);
    }
    
    // central line
    Rectangle {
        id: centralLine
        width: parent.width
        height: 3
        anchors.verticalCenter: parent.verticalCenter
        color: "#e0e0e0"
    }
    
    // below centre line
    ListView {
        model: visualization.volumes
        orientation: Qt.Horizontal
        
        anchors.top: centralLine.top
        height: 70
        width: parent.width
        
        delegate: Item {
            width: 4
            Rectangle {
                color: "#616161"
                width: 2
                height: 70 * modelData / 1000
                antialiasing: true
            }
        }
    }
    
    // above centre line
    ListView {
        model: visualization.volumes
        orientation: Qt.Horizontal
        
        anchors.top: centralLine.top
        height: 70
        width: parent.width
        
        delegate: Item {
            width: 4
            Rectangle {
                color: "#616161"
                width: 2
                height: 70 * modelData / 1000
                antialiasing: true
                y: -height
            }
        }
    }
    
    

//     Charts.LineChart {
//         smooth: true
//         id: lineChart
// 
//         anchors.fill: parent
//         valueSources: [
//             Charts.ArraySource { array: visualization.volumes }
//         ]
//     }

    
}
