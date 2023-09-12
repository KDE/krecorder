/*
 * Copyright 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard

import KRecorder 1.0

FormCard.AboutPage {
    id: aboutPage
    aboutData: AboutType.aboutData
}
