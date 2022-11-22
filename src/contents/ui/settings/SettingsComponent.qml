// SPDX-FileCopyrightText: 2022 Devin Lin <espidev@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.0
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1

import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import KRecorder 1.0

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

    MobileForm.FormCard {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true

        contentItem: ColumnLayout {
            spacing: 0

            MobileForm.FormCardHeader {
                title: i18n("General")
            }

            MobileForm.FormButtonDelegate {
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

            MobileForm.FormDelegateSeparator { above: aboutDelegate; below: audioFormatDropdown }

            MobileForm.FormComboBoxDelegate {
                id: audioFormatDropdown
                text: i18n("Audio Format")
                // the order here must match the one in settingsmodel
                model: [i18nc("Ogg Vorbis file format", "Ogg Vorbis"), i18nc("Ogg Opus file format", "Ogg Opus"), i18nc("FLAC file format", "FLAC"), i18nc("MP3 file format", "MP3"), i18n("WAV file format", "WAV"), i18nc("File format not listed", "Other")] 
                onCurrentValueChanged: SettingsModel.simpleAudioFormat = currentIndex;
                displayMode: MobileForm.FormComboBoxDelegate.Dialog
                
                Binding on currentIndex {
                    value: SettingsModel.simpleAudioFormat
                }

                onClicked: if (root.dialog && audioFormatDropdown.displayMode === MobileForm.FormComboBoxDelegate.Dialog) {
                    dialogTimer.dialog = audioFormatDropdown.dialog;
                    dialogTimer.restart();
                }

                Connections {
                    target: audioFormatDropdown.dialog
                    function onClosed() {
                        if (root.dialog) {
                            root.dialog.open();
                        }
                    }
                }
            }

            MobileForm.FormDelegateSeparator { above: audioFormatDropdown; below: audioQualityDropdown }

            MobileForm.FormComboBoxDelegate {
                id: audioQualityDropdown
                text: i18n("Audio Quality")
                model: [i18n("Lowest"), i18n("Low"), i18n("Medium"), i18n("High"), i18n("Highest")]
                description: i18n("Higher audio quality also increases file size.")
                onCurrentValueChanged: SettingsModel.audioQuality = currentIndex;
                displayMode: MobileForm.FormComboBoxDelegate.Dialog
                
                Binding on currentIndex {
                    value: SettingsModel.audioQuality
                }
                
                onClicked: if (root.dialog && audioQualityDropdown.displayMode === MobileForm.FormComboBoxDelegate.Dialog) {
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
    }

    MobileForm.FormCard {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing

        contentItem: ColumnLayout {
            spacing: 0

            MobileForm.FormCardHeader {
                title: i18n("Advanced")
            }

            MobileForm.FormComboBoxDelegate {
                id: audioInputDropdown
                text: i18n("Audio Input")
                model: AudioRecorder.audioInputs
                onCurrentValueChanged: AudioRecorder.audioInput = currentValue;
                displayMode: MobileForm.FormComboBoxDelegate.Dialog
                
                Binding on currentIndex {
                    value: audioInputDropdown.indexOfValue(AudioRecorder.audioInput)
                }
                
                Component.onCompleted: {
                    // HACK: the values don't load until after the component completes
                    currentIndex = audioInputDropdown.indexOfValue(AudioRecorder.audioInput)
                }

                onClicked: if (root.dialog && audioInputDropdown.displayMode === MobileForm.FormComboBoxDelegate.Dialog) {
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

            MobileForm.FormDelegateSeparator { above: audioInputDropdown; below: audioCodecDropdown }

            MobileForm.FormComboBoxDelegate {
                id: audioCodecDropdown
                text: i18n("Audio Codec")
                model: AudioRecorder.supportedAudioCodecs
                onCurrentValueChanged: AudioRecorder.audioCodec = currentValue;
                displayMode: MobileForm.FormComboBoxDelegate.Dialog
                
                Binding on currentIndex {
                    value: audioCodecDropdown.indexOfValue(SettingsModel.audioCodec)
                }
                
                Component.onCompleted: {
                    // HACK: the values don't load until after the component completes
                    currentIndex = audioCodecDropdown.indexOfValue(SettingsModel.audioCodec)
                }

                onClicked: if (root.dialog && audioCodecDropdown.displayMode === MobileForm.FormComboBoxDelegate.Dialog) {
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

            MobileForm.FormDelegateSeparator { above: audioCodecDropdown; below: containerFormatDropdown }

            MobileForm.FormComboBoxDelegate {
                id: containerFormatDropdown
                text: i18n("Container Format")
                model: AudioRecorder.supportedContainers
                onCurrentValueChanged: SettingsModel.containerFormat = currentValue;
                displayMode: MobileForm.FormComboBoxDelegate.Dialog

                Binding on currentIndex {
                    value: containerFormatDropdown.indexOfValue(SettingsModel.containerFormat)
                }
                
                Component.onCompleted: {
                    // HACK: the values don't load until after the component completes
                    currentIndex = containerFormatDropdown.indexOfValue(SettingsModel.containerFormat)
                }
                
                onClicked: if (root.dialog && containerFormatDropdown.displayMode === MobileForm.FormComboBoxDelegate.Dialog) {
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
        }
    }

    MobileForm.FormSectionText {
        text: i18n("Some combinations of codecs and container formats may not be compatible.")
    }
}
