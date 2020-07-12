/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "utils.h"

#include <QDateTime>
#include <QRandomGenerator>

Utils::Utils(QObject *parent) : QObject(parent)
{
}

QString Utils::formatDateTime(const QString &datetime)
{
    return QDateTime::fromString(datetime, Qt::TextDate).toString(Qt::DefaultLocaleShortDate);
}

QString Utils::formatTime(int time)
{
    return QTime::fromMSecsSinceStartOfDay(time).toString();
}
