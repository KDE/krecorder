/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2

import QtQml 2.14
import QtMultimedia 5.12

import org.kde.kirigami 2.12 as Kirigami

import KRecorder 1.0
import "settings"

Kirigami.ApplicationWindow {
    id: appwindow

    title: i18n("Recorder")

    width: Kirigami.Settings.isMobile ? 400 : 800
    height: Kirigami.Settings.isMobile ? 550 : 500
    
    property bool isWidescreen: appwindow.wideScreen && appwindow.width >= appwindow.height // prevent being widescreen at first launch
    property Recording currentRecording: null
    
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar;
    pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;
    
    pageStack.initialPage: RecordingListPage {}
    pageStack.columnView.columnResizeMode: isWidescreen ? Kirigami.ColumnView.FixedColumns : Kirigami.ColumnView.SingleColumn
    
    color: "transparent"
    
    Component.onCompleted: {
        switchToRecording(null);
        
        if (!Kirigami.Settings.isMobile) {
            SettingsModel.setBlur(pageStack, true);
        }
    }
    
    // page switch animation
    NumberAnimation {
        id: anim
        from: 0
        to: 1
        duration: Kirigami.Units.longDuration * 2
        easing.type: Easing.InOutQuad
    }
    NumberAnimation {
        id: yAnim
        from: Kirigami.Units.gridUnit * 3
        to: 0
        duration: Kirigami.Units.longDuration * 3
        easing.type: Easing.OutQuint
    }
    
    // pop pages when not in use
    Connections {
        target: applicationWindow().pageStack
        function onCurrentIndexChanged() {
            // wait for animation to finish before popping pages
            closePageTimer.restart();
        }
    }
    
    Timer {
        id: closePageTimer
        interval: 300
        onTriggered: {
            // only close pages automatically when in narrow screen mode
            if (!applicationWindow().isWidescreen) {
                let currentIndex = applicationWindow().pageStack.currentIndex;
                while (applicationWindow().pageStack.depth > (currentIndex + 1) && currentIndex >= 0) {
                    applicationWindow().pageStack.pop();
                }
            }
        }
    }
    
    Loader {
        id: playerPageLoader
    }
    
    onIsWidescreenChanged: switchToRecording(currentRecording);
    
    function openSettings() {
        if (isWidescreen) {
            settingsDialogLoader.active = true;
            settingsDialogLoader.item.open();
        } else {
            pageStack.push("qrc:/settings/SettingsPage.qml");
        }
    }
    
    function switchToRecording(recording) {
        currentRecording = recording;
        while (pageStack.depth > 1) pageStack.pop();

        if (recording == null) {
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
        
        // page switch animation
        yAnim.target = playerPageLoader.item;
        yAnim.properties = "yTranslate";
        anim.target = playerPageLoader.item;
        anim.properties = "mainOpacity";
        yAnim.restart();
        anim.restart();
    }
    
    Loader {
        id: settingsDialogLoader
        active: false
        sourceComponent: SettingsDialog {}
    }
}

