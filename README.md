<!--
- SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
- SPDX-License-Identifier: GPL-3.0-or-later
-->

# KRecorder <img src="logo.png" width="40"/>
A convergent audio recording application for Plasma.

## Features
* Record audio with a visualizer, and pausing functionality
* Ability to select audio sources
* Ability to select encoding and container formats
* Audio playback with a visualizer

## Links
* Project page: https://invent.kde.org/plasma-mobile/krecorder
* Issues: https://bugs.kde.org/describecomponents.cgi?product=krecorder
* Development channel: https://matrix.to/#/#plasmamobile:matrix.org

## Dependencies

* extra-cmake-modules
* kconfig
* ki18n
* kirigami2 (runtime only)
* kirigami-addons (runtime only)

## Installing
```
mkdir build
cd build
cmake .. # add -DCMAKE_BUILD_TYPE=Release to compile for release
make
sudo make install
```
