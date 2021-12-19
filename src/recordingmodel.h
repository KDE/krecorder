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

class RecordingModel : public QAbstractListModel
{
    Q_OBJECT

public:
    static RecordingModel* instance();
    
    enum {
        RecordingRole,
    };
    
    void load();
    void save();
    
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QList<Recording *> &recordings();
    
    Q_INVOKABLE QString nextDefaultRecordingName();
    
    Q_INVOKABLE void insertRecording(QString filePath, QString fileName, QDateTime recordDate, int recordingLength);
    Q_INVOKABLE void deleteRecording(const int index);

private:
    explicit RecordingModel(QObject *parent = nullptr);
    ~RecordingModel();

    QSettings* m_settings;
    QList<Recording*> m_recordings;

};
