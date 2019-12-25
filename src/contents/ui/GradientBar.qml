import QtQuick 2.12

Rectangle {
    width: timeText.width
    height: 2
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0; color: "transparent" }
        GradientStop { position: 0.15; color: "#c46d9696" }
        GradientStop { position: 0.5; color: "#ff2c4e4e" }
        GradientStop { position: 0.85; color: "#c46d9696" }
        GradientStop { position: 1.0; color: "transparent" }
    }
}
