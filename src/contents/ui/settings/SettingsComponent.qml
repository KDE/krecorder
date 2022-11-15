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
                Component.onCompleted: currentIndex = model[SettingsModel.simpleAudioFormat] ? SettingsModel.simpleAudioFormat : 0
                model: [i18n("Ogg Vorbis"), i18n("Ogg Opus"), i18n("FLAC"), i18n("MP3"), i18n("WAV")]
                onCurrentValueChanged: SettingsModel.simpleAudioFormat = currentIndex;

                onClicked: if (root.dialog) {
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

            MobileForm.FormDelegateSeparator { above: audioFormatDropdown; below: audioQualityDelegate }

            MobileForm.AbstractFormDelegate {
                id: audioQualityDelegate
                Layout.fillWidth: true

                background: Item {}

                contentItem: ColumnLayout {
                    Controls.Label {
                        text: i18n("Audio Quality")
                    }

                    RowLayout {
                        spacing: Kirigami.Units.gridUnit
                        Kirigami.Icon {
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            source: "list-remove"
                        }

                        Controls.Slider {
                            id: sliderValue
                            Layout.fillWidth: true
                            from: 0
                            to: 4
                            value: SettingsModel.audioQuality
                            stepSize: 1
                            snapMode: Controls.Slider.SnapAlways
                            onMoved: SettingsModel.audioQuality = value
                        }

                        Kirigami.Icon {
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            source: "list-add"
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
                Component.onCompleted: currentIndex = indexOfValue(SettingsModel.audioInput)
                model: AudioRecorder.audioInputs

                onClicked: if (root.dialog) {
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
                Component.onCompleted: currentIndex = indexOfValue(SettingsModel.audioCodec)
                model: AudioRecorder.supportedAudioCodecs

                onClicked: if (root.dialog) {
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
                Component.onCompleted: currentIndex = indexOfValue(SettingsModel.containerFormat)
                model: AudioRecorder.supportedContainers
                onCurrentValueChanged: SettingsModel.containerFormat = currentValue;

                onClicked: if (root.dialog) {
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
