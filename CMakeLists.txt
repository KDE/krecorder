#
# SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
cmake_minimum_required(VERSION 3.16)

project(krecorder)
set(PROJECT_VERSION "21.07")

set(QT_MIN_VERSION "5.15.0")
set(KF_MIN_VERSION "5.82")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FeatureSummary)

find_package(ECM ${KF_MIN_VERSION} REQUIRED)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(ECMPoQmTools)

# setup version
ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX KRECORDER
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/version.h
)
find_package(Qt5 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core Gui Widgets Qml QuickControls2 Multimedia Svg)
find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS Kirigami2 I18n Config)

add_subdirectory(src)

install(PROGRAMS org.kde.krecorder.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.krecorder.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES org.kde.krecorder.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
