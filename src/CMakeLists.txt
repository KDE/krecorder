#
# SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

set(krecorder_SRCS
    main.cpp
    audiorecorder.cpp
    audioplayer.cpp
    recordingmodel.cpp
    audioprober.cpp
    utils.cpp
    settingsmodel.cpp
    resources.qrc
)

add_executable(krecorder ${krecorder_SRCS})
target_link_libraries(krecorder 
    Qt5::Core 
    Qt5::Gui 
    Qt5::Qml 
    Qt5::Quick 
    Qt5::Widgets 
    Qt5::QuickControls2 
    Qt5::Multimedia
    Qt5::Svg
    KF5::I18n
    KF5::ConfigGui
)

target_include_directories(krecorder PRIVATE ${CMAKE_BINARY_DIR})

install(TARGETS krecorder ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

if(ANDROID)
    kirigami_package_breeze_icons(ICONS
        media-playback-pause media-playback-start
        media-playback-stop media-record audio-input-microphone-symbolic
        entry-edit delete settings-configure
    )
endif()
