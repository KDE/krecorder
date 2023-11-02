// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import KRecorder

ColumnLayout {
    id: root
    property var dialog: null // dialog component if this is within a dialog

    spacing: 0

    signal closeRequested()

    // HACK: dialog switching requires some time between closing and opening
    Timer {
        id: dialogTimer
        interval: 1
        property var dialog
        onTriggered: {
            root.dialog.close();
            dialog.open();
        }
    }

    FormCard.FormHeader {
        title: i18n("General")
    }

    FormCard.FormCard {
        FormCard.FormButtonDelegate {
            id: aboutDelegate
            text: i18n("About")
            onClicked: {
                if (applicationWindow().isWidescreen) {
                    applicationWindow().pageStack.layers.push("qrc:/AboutPage.qml");
                } else {
                    applicationWindow().pageStack.push("qrc:/AboutPage.qml");
                }

                if (root.dialog) {
                    root.dialog.close();
                }
            }
        }
    }

    FormCard.FormHeader {
        title: i18n("Advanced")
    }

    FormCard.FormCard {
        FormCard.FormComboBoxDelegate {
            id: audioInputDropdown
            text: i18n("Audio Input")
            model: AudioRecorder.audioInputs
            onCurrentValueChanged: AudioRecorder.audioInput = currentValue;
            displayMode: FormCard.FormComboBoxDelegate.Dialog
            
            Binding on currentIndex {
                value: audioInputDropdown.indexOfValue(AudioRecorder.audioInput)
            }
            
            Component.onCompleted: {
                // HACK: the values don't load until after the component completes
                currentIndex = audioInputDropdown.indexOfValue(AudioRecorder.audioInput)
            }

            onClicked: if (root.dialog && audioInputDropdown.displayMode === FormCard.FormComboBoxDelegate.Dialog) {
                dialogTimer.dialog = audioInputDropdown.dialog;
                dialogTimer.restart();
            }

            Connections {
                target: audioInputDropdown.dialog
                function onClosed() {
                    if (root.dialog) {
                        root.dialog.open();
                    }
                }
            }
        }

        FormCard.FormComboBoxDelegate {
            id: audioCodecDropdown
            text: i18n("Audio Codec")
            model: AudioRecorder.supportedAudioCodecs
            onCurrentValueChanged: AudioRecorder.audioCodec = currentValue;
            displayMode: FormCard.FormComboBoxDelegate.Dialog
            
            Binding on currentIndex {
                value: audioCodecDropdown.indexOfValue(SettingsModel.audioCodec)
            }
            
            Component.onCompleted: {
                // HACK: the values don't load until after the component completes
                currentIndex = audioCodecDropdown.indexOfValue(SettingsModel.audioCodec)
            }

            onClicked: if (root.dialog && audioCodecDropdown.displayMode === FormCard.FormComboBoxDelegate.Dialog) {
                dialogTimer.dialog = audioCodecDropdown.dialog;
                dialogTimer.restart();
            }

            Connections {
                target: audioCodecDropdown.dialog
                function onClosed() {
                    if (root.dialog) {
                        root.dialog.open();
                    }
                }
            }
        }

        FormCard.FormComboBoxDelegate {
            id: containerFormatDropdown
            text: i18n("Container Format")
            model: AudioRecorder.supportedContainers
            onCurrentValueChanged: SettingsModel.containerFormat = currentValue;
            displayMode: FormCard.FormComboBoxDelegate.Dialog

            Binding on currentIndex {
                value: containerFormatDropdown.indexOfValue(SettingsModel.containerFormat)
            }
            
            Component.onCompleted: {
                // HACK: the values don't load until after the component completes
                currentIndex = containerFormatDropdown.indexOfValue(SettingsModel.containerFormat)
            }
            
            onClicked: if (root.dialog && containerFormatDropdown.displayMode === FormCard.FormComboBoxDelegate.Dialog) {
                dialogTimer.dialog = containerFormatDropdown.dialog;
                dialogTimer.restart();
            }

            Connections {
                target: containerFormatDropdown.dialog
                function onClosed() {
                    if (root.dialog) {
                        root.dialog.open();
                    }
                }
            }
        }

        FormCard.FormComboBoxDelegate {
            id: audioQualityDropdown
            text: i18n("Audio Quality")
            model: [i18n("Lowest"), i18n("Low"), i18n("Medium"), i18n("High"), i18n("Highest")]
            description: i18n("Higher audio quality also increases file size.")
            onCurrentValueChanged: SettingsModel.audioQuality = currentIndex;
            displayMode: FormCard.FormComboBoxDelegate.Dialog

            Binding on currentIndex {
                value: SettingsModel.audioQuality
            }

            onClicked: if (root.dialog && audioQualityDropdown.displayMode === FormCard.FormComboBoxDelegate.Dialog) {
                dialogTimer.dialog = audioQualityDropdown.dialog;
                dialogTimer.restart();
            }

            Connections {
                target: audioQualityDropdown.dialog
                function onClosed() {
                    if (root.dialog) {
                        root.dialog.open();
                    }
                }
            }
        }
    }

    FormCard.FormSectionText {
        text: i18n("Some combinations of codecs and container formats may not be compatible.")
    }
}
