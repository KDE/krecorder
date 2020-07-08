import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2 as Controls

// import org.kde.quickcharts 1.0 as Charts

Item {
    id: visualization
    
    property int maxBarHeight
    property int animationIndex // which index rectangle is being expanded
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
        
        interactive: false
        anchors.top: centralLine.top
        height: maxBarHeight
        width: parent.width
        
        delegate: Item {
            width: 4
            Rectangle {
                id: rect
                color: "#616161"
                width: 2
                height: index == animationIndex ? 0 : maxBarHeight * modelData / 1000
                antialiasing: true
                
                Behavior on height {
                    SmoothedAnimation {
                        duration: 500
                    }
                }
            }
        }
    }
    
    // above centre line
    ListView {
        model: visualization.volumes
        orientation: Qt.Horizontal
        
        interactive: false
        anchors.top: centralLine.top
        height: maxBarHeight
        width: parent.width
        
        delegate: Item {
            width: 4
            Rectangle {
                color: "#616161"
                width: 2
                height: index == animationIndex ? 0 : maxBarHeight * modelData / 1000
                antialiasing: true
                y: -height
                
                Behavior on height {
                    SmoothedAnimation {
                        duration: 500
                    }
                }
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
