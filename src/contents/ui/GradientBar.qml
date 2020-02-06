import QtQuick 2.12

Rectangle {
    width: timeText.width
    height: 1
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
        GradientStop { position: 0.15; color: Qt.rgba(1, 1, 1, 0.5) }
        GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 1) }
        GradientStop { position: 0.85; color: Qt.rgba(1, 1, 1, 0.5) }
        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
    }
}
