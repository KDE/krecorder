/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QDateTime>
#include <QJsonObject>
#include <QObject>

class Recording : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY propertyChanged)
    Q_PROPERTY(QString fileExtension READ fileExtension NOTIFY propertyChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY propertyChanged)
    Q_PROPERTY(QString recordDate READ recordDatePretty NOTIFY propertyChanged)
    Q_PROPERTY(QString recordingLength READ recordingLengthPretty NOTIFY propertyChanged)

public:
    explicit Recording(QObject *parent = nullptr,
                       const QString &filePath = {},
                       const QString &fileName = {},
                       QDateTime recordDate = QDateTime::currentDateTime(),
                       int recordingLength = 0);
    explicit Recording(QObject *parent, const QJsonObject &obj);

    QJsonObject toJson() const;

    QString filePath() const;
    QString fileName() const;
    QString fileExtension() const;

    QDateTime recordDate() const;
    QString recordDatePretty() const;

    int recordingLength() const;
    QString recordingLengthPretty() const;

    void setFilePath(const QString &filePath);
    void setFileName(const QString &fileName);

    void setRecordDate(const QDateTime &date);
    void setRecordingLength(int recordingLength);

    Q_INVOKABLE void createCopyOfFile(const QString &path);

private:
    QString m_filePath, m_fileName;
    QDateTime m_recordDate;
    int m_recordingLength; // seconds

Q_SIGNALS:
    void propertyChanged();
};
