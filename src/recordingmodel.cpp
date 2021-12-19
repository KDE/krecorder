/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "recordingmodel.h"

#include <QFile>
#include <QStandardPaths>
#include <QJsonObject>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>

#include "utils.h"

const QString DEF_RECORD_PREFIX = QStringLiteral("clip");

RecordingModel* RecordingModel::instance()
{
    static RecordingModel *recordingModel = new RecordingModel(qApp);
    return recordingModel;
}

RecordingModel::RecordingModel(QObject *parent) 
    : QObject{ parent }
{
    m_settings = new QSettings(parent);
    load();
}

RecordingModel::~RecordingModel()
{
    save();
    delete m_settings;

    qDeleteAll(m_recordings);
}

void RecordingModel::load()
{
    QJsonDocument doc = QJsonDocument::fromJson(m_settings->value(QStringLiteral("recordings")).toString().toUtf8());

    const auto array = doc.array();
    std::transform(array.begin(), array.end(), std::back_inserter(m_recordings), [this](const QJsonValue &rec) {
        return new Recording(this, rec.toObject());
    });
    
    Q_EMIT recordingsChanged();
}

void RecordingModel::save()
{
    QJsonArray arr;

    const auto recordings = qAsConst(m_recordings);
    std::transform(recordings.begin(), recordings.end(), std::back_inserter(arr), [](const Recording *recording) {
        return QJsonValue(recording->toJson());
    });
    
    m_settings->setValue(QStringLiteral("recordings"), QString::fromStdString(QJsonDocument(arr).toJson(QJsonDocument::Compact).toStdString()));
}

QList<Recording *> &RecordingModel::recordings()
{
    return m_recordings;
}

QString RecordingModel::nextDefaultRecordingName()
{
    QSet<QString> s;

    for (const auto &rec : qAsConst(m_recordings)) {
        s.insert(rec->fileName());
    }

    // determine valid clip name (ex. clip_0001, clip_0002, etc.)
    
    int num = 1;
    QString build = QStringLiteral("0001");
        
    while (s.contains(DEF_RECORD_PREFIX + QStringLiteral("_") + build)) {
        num++;
        build = QString::number(num);
        while (build.length() < 4) {
            build = QStringLiteral("0") + build;
        }
    }
    
    return DEF_RECORD_PREFIX + QStringLiteral("_") + build;
}


void RecordingModel::insertRecording(QString filePath, QString fileName, QDateTime recordDate, int recordingLength)
{
    qDebug() << "Adding recording " << filePath;
    
    m_recordings.insert(0, new Recording(this, filePath, fileName, recordDate, recordingLength));
    Q_EMIT recordingsChanged();
    
    save();
}

void RecordingModel::deleteRecording(const int index)
{
    qDebug() << "Removing recording " << m_recordings[index]->filePath();
    
    QFile::remove(m_recordings[index]->filePath());
    m_recordings.removeAt(index);
    Q_EMIT recordingsChanged();
    
    save();
}

