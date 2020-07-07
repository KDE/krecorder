import QtQuick 2.0
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.8 as Kirigami
import KRecorder 1.0

Kirigami.ScrollablePage {
    title: i18n("Advanced Settings")
    property AudioRecorder recorder: null

    Kirigami.FormLayout {
        Controls.ComboBox {
            Kirigami.FormData.label: i18n("Audio Input")
            currentIndex: recorder.audioInputs.indexOf(recorder.audioInput)
            model: recorder.audioInputs
            onCurrentValueChanged: recorder.audioInput = currentValue
        }
        Controls.ComboBox {
            Kirigami.FormData.label: i18n("Audio Codec")
            currentIndex: recorder.supportedAudioCodecs.indexOf(recorder.audioCodec)
            model: recorder.supportedAudioCodecs
            onCurrentValueChanged: recorder.audioCodec = currentValue
        }
        Controls.ComboBox {
            Kirigami.FormData.label: i18n("Container Format")
            currentIndex: recorder.supportedContainers.indexOf(recorder.containerFormat)
            model: recorder.supportedContainers
            onCurrentValueChanged: recorder.containerFormat = currentValue
        }

        Controls.Slider {
            Kirigami.FormData.label: i18n("Audio Quality")
            value: recorder.audioQuality
            // enum values
            from: 0
            to: 4
            stepSize: 1
            onValueChanged: recorder.audioQuality = value
            snapMode: Controls.Slider.SnapAlways
        }
    }
}
