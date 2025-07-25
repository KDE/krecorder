/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import QtQml
import QtMultimedia

import org.kde.kirigami as Kirigami
import org.kde.config as KConfig

import KRecorder
import "settings"

Kirigami.ApplicationWindow {
    id: appwindow

    title: i18n("Recorder")

    width: Kirigami.Settings.isMobile ? 400 : 800
    height: Kirigami.Settings.isMobile ? 550 : 500

    readonly property real wideScreenThreshold: Kirigami.Units.gridUnit * 40
    readonly property bool isWidescreen: (appwindow.width >= wideScreenThreshold) && appwindow.wideScreen // prevent being widescreen at first launch

    property Recording currentRecording: null

    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar;
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;

    pageStack.initialPage: RecordingListPage {}
    pageStack.columnView.columnResizeMode: isWidescreen ? Kirigami.ColumnView.FixedColumns : Kirigami.ColumnView.SingleColumn
    pageStack.popHiddenPages: true

    KConfig.WindowStateSaver {
        configGroupName: "MainWindow"
    }

    Component.onCompleted: {
        switchToRecording(null);
    }

    Loader {
        id: playerPageLoader
    }

    onIsWidescreenChanged: switchToRecording(currentRecording);

    function openSettings() {
        if (isWidescreen) {
            settingsDialogLoader.active = true;

            if (Kirigami.Settings.isMobile) {
                // SettingsDialog
                settingsDialogLoader.item.open();
            } else {
                // SettingsWindow
                settingsDialogLoader.item.close();
                settingsDialogLoader.item.show();
            }
        } else {
            pageStack.push("qrc:/settings/SettingsPage.qml");
        }
    }

    function openRecordScreen() {
        pageStack.layers.push(recordPage);

        // if not in a recording session, start recording
        if (recordPage.isStopped) {
            AudioRecorder.record();
        }
    }

    function switchToRecording(recording) {
        currentRecording = recording;
        while (pageStack.depth > 1) pageStack.pop();

        if (recording == null) {
            AudioPlayer.setMediaPath(null);

            if (isWidescreen) {
                playerPageLoader.setSource("qrc:/DefaultPage.qml");
                pageStack.push(playerPageLoader.item);
            }
        } else {
            AudioPlayer.setVolume(100);
            AudioPlayer.setMediaPath(recording.filePath)
            AudioPlayer.play()
            playerPageLoader.setSource("qrc:/PlayerPage.qml", {recording: recording});
            pageStack.push(playerPageLoader.item);
        }
    }

    // record page
    RecordPage {
        id: recordPage
        visible: false
    }

    Loader {
        id: settingsDialogLoader
        active: false
        source: Kirigami.Settings.isMobile ? "qrc:/settings/SettingsDialog.qml" : "qrc:/settings/SettingsWindow.qml"
    }
}

