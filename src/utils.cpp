/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "utils.h"

#include <QDateTime>
#include <QLocale>
#include <QRandomGenerator>

Utils::Utils(QObject *parent)
    : QObject(parent)
{
}

QString Utils::formatDateTime(const QString &datetime)
{
    return QDateTime::fromString(datetime, Qt::TextDate).toString(QLocale().dateTimeFormat(QLocale::ShortFormat));
}

QString Utils::formatTime(int time)
{
    return QTime::fromMSecsSinceStartOfDay(time).toString();
}

QString Utils::formatDuration(int duration)
{
    // assume duration is in milliseconds
    duration /= 1000;
    const int min = duration / 60;
    const int sec = duration - min * 60;
    return QStringLiteral("%1:%2").arg(min).arg(sec, 2, 10, QLatin1Char('0'));
}
