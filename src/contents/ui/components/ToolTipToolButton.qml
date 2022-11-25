/*
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami
import QtQuick.Controls 2.15 as Controls

Controls.ToolButton {
    display: Controls.AbstractButton.IconOnly
    
    Controls.ToolTip.delay: Kirigami.Units.toolTipDelay
    Controls.ToolTip.timeout: 5000
    Controls.ToolTip.visible: Kirigami.Settings.tabletMode ? pressed : hovered
    Controls.ToolTip.text: text
}
