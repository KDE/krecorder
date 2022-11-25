/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "recording.h"

#include <QFile>
#include <QStandardPaths>
#include <QJsonObject>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>

#include "utils.h"

Recording::Recording(QObject *parent, const QString &filePath, const QString &fileName, QDateTime recordDate, int recordingLength)
    : QObject{ parent }
    , m_filePath{ filePath }
    , m_fileName{ fileName }
    , m_recordDate{ recordDate }
    , m_recordingLength{ recordingLength }
{}

Recording::Recording(QObject *parent, const QJsonObject &obj)
    : QObject{ parent }
    , m_filePath{ obj[QStringLiteral("filePath")].toString() }
    , m_fileName{ obj[QStringLiteral("fileName")].toString() }
    , m_recordDate{ QDateTime::fromString(obj[QStringLiteral("recordDate")].toString(), Qt::DateFormat::ISODate) }
    , m_recordingLength{ obj[QStringLiteral("recordingLength")].toInt() }
{}

QJsonObject Recording::toJson() const
{
    QJsonObject obj;
    obj[QStringLiteral("filePath")] = m_filePath;
    obj[QStringLiteral("fileName")] = m_fileName;
    obj[QStringLiteral("recordDate")] = m_recordDate.toString(Qt::DateFormat::ISODate);
    obj[QStringLiteral("recordingLength")] = m_recordingLength;
    return obj;
}

QString Recording::filePath() const
{
    return m_filePath;
}

QString Recording::fileName() const
{
    return m_fileName;
}

QString Recording::fileExtension() const
{
    auto split = m_filePath.split(QStringLiteral("."));
    if (split.length() > 0) {
        return split[split.length() - 1];
    }
    return QString{};
}

QDateTime Recording::recordDate() const
{
    return m_recordDate;
}

QString Recording::recordDatePretty() const
{
    return m_recordDate.toString(QStringLiteral("yyyy-MM-dd"));
}

int Recording::recordingLength() const
{
    return m_recordingLength;
}

QString Recording::recordingLengthPretty() const
{
    const int min = m_recordingLength / 60;
    const int sec = m_recordingLength - min * 60;
    return QStringLiteral("%1:%2").arg(min).arg(sec, 2, 10, QLatin1Char('0'));
}

void Recording::setFilePath(const QString &filePath)
{
    QFile(m_filePath).rename(filePath);
    m_filePath = filePath;

    QStringList spl = filePath.split(QStringLiteral("/"));
    m_fileName = spl[spl.size()-1].split(QStringLiteral("."))[0];

    Q_EMIT propertyChanged();
}

void Recording::setFileName(const QString &fileName)
{
    QString oldPath = m_filePath;

    m_filePath.replace(QRegExp(m_fileName + QStringLiteral("(?!.*") + m_fileName + QStringLiteral(")")), fileName);
    QFile(oldPath).rename(m_filePath);

    m_fileName = fileName;
    Q_EMIT propertyChanged();
}

void Recording::setRecordDate(const QDateTime &date)
{
    m_recordDate = date;
    Q_EMIT propertyChanged();
}

void Recording::setRecordingLength(int recordingLength)
{
    m_recordingLength = recordingLength;
    Q_EMIT propertyChanged();
}

void Recording::createCopyOfFile(const QString &path)
{
    QFile::copy(m_filePath, path);
}
