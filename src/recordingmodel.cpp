/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
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

const QString DEF_RECORD_PREFIX = "clip";

/* ~ Recording ~ */

Recording::Recording(QObject* parent, const QString &filePath, const QString &fileName, QDateTime recordDate, int recordingLength)
    : QObject(parent)
    , m_filePath(filePath)
    , m_fileName(fileName)
    , m_recordDate(recordDate)
    , m_recordingLength(recordingLength)
{}

Recording::Recording(const QJsonObject &obj)
    : m_filePath(obj["filePath"].toString())
    , m_fileName(obj["fileName"].toString())
    , m_recordDate(QDateTime::fromString(obj["recordDate"].toString(), Qt::DateFormat::ISODate))
    , m_recordingLength(obj["recordingLength"].toInt())
{
}

Recording::~Recording()
{
}


QJsonObject Recording::toJson() const
{
    QJsonObject obj;
    obj["filePath"] = m_filePath;
    obj["fileName"] = m_fileName;
    obj["recordDate"] = m_recordDate.toString(Qt::DateFormat::ISODate);
    obj["recordingLength"] = m_recordingLength;
    return obj;
}

QString Recording::recordingLengthPretty() const
{
    const int hours = m_recordingLength / 60 / 60;
    const int min = m_recordingLength / 60 - hours * 60;
    const int sec = m_recordingLength - min * 60 - hours * 60 * 60;
    return QStringLiteral("%1:%2:%3").arg(hours, 2, 10, QLatin1Char('0')).arg(min, 2, 10, QLatin1Char('0')).arg(sec, 2, 10, QLatin1Char('0'));
}

void Recording::setFilePath(const QString &filePath)
{
    QFile(m_filePath).rename(filePath);
    m_filePath = filePath;

    QStringList spl = filePath.split("/");
    m_fileName = spl[spl.size()-1].split(".")[0];

    emit propertyChanged();
}

void Recording::setFileName(const QString &fileName)
{
    QString oldPath = m_filePath;

    m_filePath.replace(QRegExp(m_fileName + "(?!.*" + m_fileName + ")"), fileName);
    QFile(oldPath).rename(m_filePath);

    m_fileName = fileName;
    emit propertyChanged();
}

void Recording::setRecordDate(const QDateTime &date)
{
    m_recordDate = date;
    emit propertyChanged();
}

void Recording::setRecordingLength(int recordingLength)
{
    m_recordingLength = recordingLength;
    emit propertyChanged();
}


/* ~ RecordingModel ~ */

RecordingModel::RecordingModel(QObject *parent) : QAbstractListModel(parent)
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
    std::transform(array.begin(), array.end(), std::back_inserter(m_recordings), [](const QJsonValue &rec) {
        return new Recording(rec.toObject());
    });
}

void RecordingModel::save()
{
    QJsonArray arr;

    const auto recordings = qAsConst(m_recordings);
    std::transform(recordings.begin(), recordings.end(), std::back_inserter(arr), [](const Recording *recording) {
        return QJsonValue(recording->toJson());
    });
    
    m_settings->setValue(QStringLiteral("recordings"), QString(QJsonDocument(arr).toJson(QJsonDocument::Compact)));
}

QHash<int, QByteArray> RecordingModel::roleNames() const
{
    return {{Roles::RecordingRole, "recording"}};
}

QVariant RecordingModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_recordings.count() || index.row() < 0)
        return {};

    auto *recording = m_recordings.at(index.row());
    if (role == Roles::RecordingRole)
        return QVariant::fromValue(recording);

    return {};
}

int RecordingModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_recordings.count();
}

QString RecordingModel::nextDefaultRecordingName()
{
    QSet<QString> s;

    for (const auto &rec : qAsConst(m_recordings)) {
        s.insert(rec->fileName());
    }

    // determine valid clip name (ex. clip_0001, clip_0002, etc.)
    
    int num = 1;
    QString build = "0001";
        
    while (s.contains(DEF_RECORD_PREFIX + "_" + build)) {
        num++;
        build = QString::number(num);
        while (build.length() < 4) {
            build = "0" + build;
        }
    }
    
    return DEF_RECORD_PREFIX + "_" + build;
}


void RecordingModel::insertRecording(QString filePath, QString fileName, QDateTime recordDate, int recordingLength)
{
    qDebug() << "Adding recording " << filePath;
    
    Q_EMIT beginInsertRows({}, 0, 0);
    m_recordings.insert(0, new Recording(this, filePath, fileName, recordDate, recordingLength));
    Q_EMIT endInsertRows();
    
    save();
}

void RecordingModel::deleteRecording(const int index)
{
    qDebug() << "Removing recording " << m_recordings[index]->filePath();
    
    QFile::remove(m_recordings[index]->filePath());
    beginRemoveRows({}, index, index);
    m_recordings.removeAt(index);
    endRemoveRows();
    
    save();
}

