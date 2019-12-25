import QtQuick 2.7
import org.kde.kirigami 2.4 as Kirigami

Rectangle {
    width: 50
    color: "#ff2c4e4e"
    Behavior on height {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
        }
    }
}
