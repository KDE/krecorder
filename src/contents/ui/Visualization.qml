import QtQuick 2.0
import QtQuick.Layouts 1.12

import org.kde.quickcharts 1.0 as Charts

Item {
    id: visualization
    height: 500
    property var volumes: []

    Charts.LineChart {
        smooth: true
        id: lineChart

        anchors.fill: parent
        valueSources: [
            Charts.ArraySource { array: visualization.volumes }
        ]
    }
}
