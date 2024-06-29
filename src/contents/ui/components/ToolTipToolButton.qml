/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami
import QtQuick.Controls as Controls

Controls.ToolButton {
    display: Controls.AbstractButton.IconOnly

    Controls.ToolTip.delay: Kirigami.Units.toolTipDelay
    Controls.ToolTip.timeout: 5000
    Controls.ToolTip.visible: Kirigami.Settings.tabletMode ? pressed : hovered
    Controls.ToolTip.text: text
}
