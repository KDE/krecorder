/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QObject>
#include <QAbstractListModel>
#include <QSettings>
#include <QFile>
#include <QJsonObject>
#include <QDateTime>
#include <QCoreApplication>

#include "recording.h"

class RecordingModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<Recording *> recordings READ recordings NOTIFY recordingsChanged)

public:
    static RecordingModel* instance();
    
    void load();
    void save();

    QList<Recording *> &recordings();
    
    Q_INVOKABLE QString nextDefaultRecordingName();
    
    Q_INVOKABLE void insertRecording(QString filePath, QString fileName, QDateTime recordDate, int recordingLength);
    Q_INVOKABLE void deleteRecording(const int index);

private:
    explicit RecordingModel(QObject *parent = nullptr);
    ~RecordingModel();

    QSettings* m_settings;
    QList<Recording*> m_recordings;
    
Q_SIGNALS:
    void recordingsChanged();

};
