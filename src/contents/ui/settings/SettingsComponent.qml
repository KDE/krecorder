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
                currentValue: model[SettingsModel.simpleAudioFormat] ? model[SettingsModel.simpleAudioFormat] : i18n("Custom") 
                model: [i18n("Ogg Vorbis"), i18n("Ogg Opus"), i18n("FLAC"), i18n("MP3"), i18n("WAV")]
                
                onClicked: {
                    if (root.dialog) {
                        dialogTimer.dialog = audioFormatDropdown.dialog;
                        dialogTimer.restart();
                    }
                }
                
                Connections {
                    target: audioFormatDropdown.dialog
                    function onClosed() {
                        if (root.dialog) {
                            root.dialog.open();
                        }
                    }
                }
                
                dialogDelegate: Controls.RadioDelegate {
                    implicitWidth: Kirigami.Units.gridUnit * 16
                    topPadding: Kirigami.Units.smallSpacing * 2
                    bottomPadding: Kirigami.Units.smallSpacing * 2
                    
                    text: modelData
                    checked: audioFormatDropdown.currentValue == modelData
                    onCheckedChanged: {
                        if (checked) {
                            SettingsModel.simpleAudioFormat = model.index;
                        }
                    }
                }
            }
            
            MobileForm.FormDelegateSeparator { above: audioFormatDropdown; below: audioQualityDelegate }
            
            MobileForm.FormComboBoxDelegate {
                id: audioQualityDelegate
                text: i18n("Audio Quality")
                currentValue: i18n("%1", sliderValue.value)
                
                onClicked: {
                    dialog.open();
                    if (root.dialog) {
                        dialogTimer.dialog = audioQualityDelegate.dialog;
                        dialogTimer.restart();
                    }
                }
                
                Connections {
                    target: audioQualityDelegate.dialog
                    function onClosed() {
                        if (root.dialog) {
                            root.dialog.open();
                        }
                    }
                }
                
                dialog: Kirigami.PromptDialog {
                    showCloseButton: false
                    title: i18n("Audio Quality")
                    
                    RowLayout {
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
                        Controls.Label {
                            text: audioQualityDelegate.currentValue
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
                currentValue: AudioRecorder.audioInput
                model: AudioRecorder.audioInputs
                
                onClicked: {
                    if (root.dialog) {
                        dialogTimer.dialog = audioInputDropdown.dialog;
                        dialogTimer.restart();
                    }
                }
                
                Connections {
                    target: audioInputDropdown.dialog
                    function onClosed() {
                        if (root.dialog) {
                            root.dialog.open();
                        }
                    }
                }
                
                dialogDelegate: Controls.RadioDelegate {
                    implicitWidth: Kirigami.Units.gridUnit * 16
                    topPadding: Kirigami.Units.smallSpacing * 2
                    bottomPadding: Kirigami.Units.smallSpacing * 2
                    
                    text: modelData
                    checked: audioInputDropdown.currentValue == modelData
                    onCheckedChanged: {
                        if (checked) {
                            AudioRecorder.audioInput = modelData;
                        }
                    }
                }
            }
            
            MobileForm.FormDelegateSeparator { above: audioInputDropdown; below: audioCodecDropdown }
            
            MobileForm.FormComboBoxDelegate {
                id: audioCodecDropdown
                text: i18n("Audio Codec")
                currentValue: SettingsModel.audioCodec
                model: AudioRecorder.supportedAudioCodecs
                
                onClicked: {
                    if (root.dialog) {
                        dialogTimer.dialog = audioCodecDropdown.dialog;
                        dialogTimer.restart();
                    }
                }
                
                Connections {
                    target: audioCodecDropdown.dialog
                    function onClosed() {
                        if (root.dialog) {
                            root.dialog.open();
                        }
                    }
                }
                
                dialogDelegate: Controls.RadioDelegate {
                    implicitWidth: Kirigami.Units.gridUnit * 16
                    topPadding: Kirigami.Units.smallSpacing * 2
                    bottomPadding: Kirigami.Units.smallSpacing * 2
                    
                    text: modelData
                    checked: audioCodecDropdown.currentValue == modelData
                    onCheckedChanged: {
                        if (checked) {
                            SettingsModel.audioCodec = modelData;
                        }
                    }
                }
            }
            
            MobileForm.FormDelegateSeparator { above: audioCodecDropdown; below: containerFormatDropdown }
            
            MobileForm.FormComboBoxDelegate {
                id: containerFormatDropdown
                text: i18n("Container Format")
                currentValue: SettingsModel.containerFormat
                model: AudioRecorder.supportedContainers
                
                onClicked: {
                    if (root.dialog) {
                        dialogTimer.dialog = containerFormatDropdown.dialog;
                        dialogTimer.restart();
                    }
                }
                
                Connections {
                    target: containerFormatDropdown.dialog
                    function onClosed() {
                        if (root.dialog) {
                            root.dialog.open();
                        }
                    }
                }
                
                dialogDelegate: Controls.RadioDelegate {
                    implicitWidth: Kirigami.Units.gridUnit * 16
                    topPadding: Kirigami.Units.smallSpacing * 2
                    bottomPadding: Kirigami.Units.smallSpacing * 2
                    
                    text: modelData
                    checked: containerFormatDropdown.currentValue == modelData
                    onCheckedChanged: {
                        if (checked) {
                            SettingsModel.containerFormat = modelData;
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