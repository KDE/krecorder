#
# SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
# SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
cmake_minimum_required(VERSION 3.16)

# KDE Applications version, managed by release script.
set(RELEASE_SERVICE_VERSION_MAJOR "24")
set(RELEASE_SERVICE_VERSION_MINOR "01")
set(RELEASE_SERVICE_VERSION_MICRO "85")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")

project(krecorder VERSION ${RELEASE_SERVICE_VERSION})

# QT_MAJOR_VERSION is defined automatically by QtVersionOption (since ECM 5.82)
# which is included by KDEInstallDirs;
# This variables are updated below if Qt6 is found by ECM
set(QT_MIN_VERSION "5.15.0")
if (ANDROID)
    set(QT_MIN_VERSION "5.15.10")
endif()
set(KF_MIN_VERSION "5.89.0")
set(KF_MAJOR_VERSION "5")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FeatureSummary)

find_package(ECM ${KF_MIN_VERSION} REQUIRED)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

# only enable QML debugging on debug builds
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DQT_QML_DEBUG ")

include(FeatureSummary)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(KDEGitCommitHooks)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(ECMPoQmTools)

if (QT_MAJOR_VERSION STREQUAL "6")
    set(QT_MIN_VERSION "6.4")
    set(KF_MIN_VERSION "5.240.0")
    set(KF_MAJOR_VERSION "6")
endif()

# setup version
ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX KRECORDER
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} REQUIRED COMPONENTS
    Core 
    Gui 
    Widgets 
    Qml 
    QuickControls2 
    Multimedia 
    Svg
)

if (QT_MAJOR_VERSION STREQUAL "5")
    find_package(Qt${QT_MAJOR_VERSION} ${QT_MIN_VERSION} REQUIRED COMPONENTS
        QuickCompiler
    )
endif()

find_package(KF${KF_MAJOR_VERSION} ${KF_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    CoreAddons
    WindowSystem
)

find_package(KF${KF_MAJOR_VERSION}Kirigami2 ${KF_MIN_VERSION})
set_package_properties(KF${KF_MAJOR_VERSION}Kirigami2 PROPERTIES
    TYPE RUNTIME
)
find_package(KF${KF_MAJOR_VERSION}KirigamiAddons 0.11 REQUIRED)

if (QT_MAJOR_VERSION STREQUAL "6")
    add_subdirectory(src)
else()
    add_subdirectory(src/qt5)
endif()

ki18n_install(po)

if (ANDROID)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android/version.gradle.in ${CMAKE_BINARY_DIR}/version.gradle)
endif()

install(PROGRAMS org.kde.krecorder.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.krecorder.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES org.kde.krecorder.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
