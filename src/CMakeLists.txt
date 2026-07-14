# SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-3.0-or-later

set(krecorder_SRCS
    main.cpp
    audioplayer.cpp
    audioprober.cpp
    audiorecorder.cpp
    recording.cpp
    recordingmodel.cpp
    settingsmodel.cpp
    utils.cpp
)

add_executable(krecorder ${krecorder_SRCS} ${RESOURCES})
target_link_libraries(krecorder PRIVATE
    Qt${QT_MAJOR_VERSION}::Core
    Qt${QT_MAJOR_VERSION}::Gui
    Qt${QT_MAJOR_VERSION}::Qml
    Qt${QT_MAJOR_VERSION}::Quick
    Qt${QT_MAJOR_VERSION}::Widgets
    Qt${QT_MAJOR_VERSION}::QuickControls2
    Qt${QT_MAJOR_VERSION}::Multimedia
    Qt${QT_MAJOR_VERSION}::Svg
    KF${KF_MAJOR_VERSION}::I18n
    KF${KF_MAJOR_VERSION}::CoreAddons
    KF${KF_MAJOR_VERSION}::ConfigCore
    KF${KF_MAJOR_VERSION}::KIOCore
)

target_include_directories(krecorder PRIVATE ${CMAKE_BINARY_DIR})

ecm_add_qml_module(krecorder URI "KRecorder"
    QML_FILES
        contents/ui/Main.qml
        contents/ui/RecordingListPage.qml
        contents/ui/RecordPage.qml
        contents/ui/PlayerPage.qml
        contents/ui/DefaultPage.qml
        contents/ui/RecordingListDelegate.qml
        contents/ui/components/Visualization.qml
        contents/ui/components/FloatingActionButton.qml
        contents/ui/components/ListDelegate.qml
        contents/ui/components/RoundFlatButton.qml
        contents/ui/components/ToolTipToolButton.qml
        contents/ui/settings/SettingsComponent.qml
        contents/ui/settings/SettingsWindow.qml
        contents/ui/settings/SettingsDialog.qml
        contents/ui/settings/SettingsPage.qml
)

install(TARGETS krecorder ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

if(ANDROID)
    kirigami_package_breeze_icons(ICONS
        media-playback-pause media-playback-start
        media-playback-stop media-record audio-input-microphone-symbolic
        entry-edit delete settings-configure
    )

    ecm_add_android_apk(krecorder ANDROID_DIR ${CMAKE_SOURCE_DIR}/android)
endif()
