#!/bin/sh

# SPDX-FileCopyrightText: 2020 Yuri Chornoivan
# SPDX-License-Identifier: GPL-3.0-or-later

$XGETTEXT `find -name \*.cpp -o -name \*.qml` -o $podir/krecorder.pot
