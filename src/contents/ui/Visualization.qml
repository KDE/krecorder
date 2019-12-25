import QtQuick 2.0
import QtQuick.Layouts 1.12

Item {
    height: 500

    property int value1
    property int value2
    property int value3
    property int value4
    property int value5

    RowLayout {
        anchors.fill: parent
        Bar {
            height: value1
        }
        Bar {
            height: value2
        }
        Bar {
            height: value3
        }
        Bar {
            height: value4
        }
        Bar {
            height: value5
        }
    }
}
