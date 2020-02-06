import QtQuick 2.0
import QtQuick.Layouts 1.12

import org.kde.quickcharts 1.0 as Charts
import org.kde.quickcharts.controls 1.0 as ChartsControls

Item {
    id: visualization
    height: 500
    property var volumes: []

    onVolumesChanged: console.log(volumes)

    ChartsControls.LineChartControl {
        id: lineChart

        anchors.fill: parent
        valueSources: [
            Charts.ArraySource { array: visualization.volumes }
        ]
    }
}
