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

qt6_add_resources(RESOURCES resources.qrc)

add_executable(krecorder ${krecorder_SRCS} ${RESOURCES})
target_link_libraries(krecorder 
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
)

target_include_directories(krecorder PRIVATE ${CMAKE_BINARY_DIR})

install(TARGETS krecorder ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

if(ANDROID)
    kirigami_package_breeze_icons(ICONS
        media-playback-pause media-playback-start
        media-playback-stop media-record audio-input-microphone-symbolic
        entry-edit delete settings-configure
    )

    ecm_add_android_apk(krecorder ANDROID_DIR ${CMAKE_SOURCE_DIR}/android)
endif()
