/*
 * Copyright 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import org.kde.kirigami 2.11 as Kirigami

import KRecorder 1.0

Kirigami.AboutPage {
    id: aboutPage
    aboutData: KRecorderAboutData
}
