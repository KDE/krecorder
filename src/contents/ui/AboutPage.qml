/*
 * Copyright 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kirigamiaddons.labs.mobileform 0.1 as MobileForm

import KRecorder 1.0

MobileForm.AboutPage {
    id: aboutPage
    aboutData: AboutType.aboutData
}
