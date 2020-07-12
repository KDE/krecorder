/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.8 as Kirigami
import KRecorder 1.0

Kirigami.ScrollablePage {
    title: i18n("Settings")
    property bool showAdvanced: false
    
    Kirigami.FormLayout {

        Controls.ComboBox {
            Kirigami.FormData.label: i18n("Format")
            model: [i18n("Ogg Vorbis"), i18n("Ogg Opus"), i18n("FLAC"), i18n("MP3"), i18n("WAV")]
            currentIndex: SettingsModel.simpleAudioFormat
            onActivated: SettingsModel.simpleAudioFormat = currentIndex
        }
        
        Controls.Slider {
            Kirigami.FormData.label: i18n("Audio Quality")
            value: SettingsModel.audioQuality
            // enum values
            from: 0
            to: 4
            stepSize: 1
            onValueChanged: SettingsModel.audioQuality = value
            snapMode: Controls.Slider.SnapAlways
        }
        
        Controls.Button {
            text: showAdvanced ? i18n("Hide Advanced Settings") : i18n("Show Advanced Settings")
            onClicked: showAdvanced = !showAdvanced
        }
        
        // advanced settings
        Controls.ComboBox {
            visible: showAdvanced
            Kirigami.FormData.label: i18n("Audio Input")
            currentIndex: AudioRecorder.audioInputs.indexOf(AudioRecorder.audioInput)
            model: AudioRecorder.audioInputs
            onActivated: AudioRecorder.audioInput = currentValue
        }
        
        Controls.ComboBox {
            visible: showAdvanced
            Kirigami.FormData.label: i18n("Audio Codec")
            currentIndex: AudioRecorder.supportedAudioCodecs.indexOf(SettingsModel.audioCodec)
            model: AudioRecorder.supportedAudioCodecs
            onActivated: SettingsModel.audioCodec = currentValue
        }
        Controls.ComboBox {
            visible: showAdvanced
            Kirigami.FormData.label: i18n("Container Format")
            currentIndex: AudioRecorder.supportedContainers.indexOf(SettingsModel.containerFormat)
            model: AudioRecorder.supportedContainers
            onActivated: SettingsModel.containerFormat = currentValue
        }
        
    }
}
