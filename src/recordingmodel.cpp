/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "recordingmodel.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>

#include <KConfigGroup>
#include <KSharedConfig>

using namespace Qt::StringLiterals;

const QString DEF_RECORD_PREFIX = QStringLiteral("clip");

RecordingModel *RecordingModel::instance()
{
    static RecordingModel *recordingModel = new RecordingModel(qApp);
    return recordingModel;
}

RecordingModel::RecordingModel(QObject *parent)
    : QAbstractListModel{parent}
{
    load();
}

RecordingModel::~RecordingModel()
{
    save();
}

int RecordingModel::count() const
{
    return m_recordings.size();
}

void RecordingModel::load()
{
    QSettings oldSettings;
    auto config = KSharedConfig::openStateConfig();

    if (oldSettings.contains("recordings")) {
        config->group(u"Recordings"_s).writeEntry("recordings", oldSettings.value("recordings"));
        oldSettings.remove("recordings");
    }

    QJsonDocument doc = QJsonDocument::fromJson(config->group(u"Recordings"_s).readEntry("recordings").toUtf8());

    beginResetModel();

    const auto array = doc.array();
    std::transform(array.begin(), array.end(), std::back_inserter(m_recordings), [this](const QJsonValue &rec) {
        return new Recording(this, rec.toObject());
    });

    // check if file exists, and delete recording if it doesn't
    for (int i = 0; i < m_recordings.size(); ++i) {
        if (!QFile::exists(m_recordings[i]->filePath())) {
            m_recordings.erase(m_recordings.begin() + i);
            --i;
        }
    }
    save();

    endResetModel();
    Q_EMIT countChanged();
}

void RecordingModel::save()
{
    QJsonArray arr;

    const auto recordings = qAsConst(m_recordings);
    std::transform(recordings.begin(), recordings.end(), std::back_inserter(arr), [](const Recording *recording) {
        return QJsonValue(recording->toJson());
    });

    auto config = KSharedConfig::openStateConfig();
    config->group(u"Recordings"_s).writeEntry("recordings", QString::fromUtf8(QJsonDocument(arr).toJson(QJsonDocument::Compact)));
}

int RecordingModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return m_recordings.size();
}

QVariant RecordingModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index)) {
        return QVariant();
    }
    if (role != RecordingRole) {
        return QVariant();
    }

    auto *recording = m_recordings[index.row()];
    return recording ? QVariant::fromValue(recording) : QVariant();
}

QHash<int, QByteArray> RecordingModel::roleNames() const
{
    return {{RecordingRole, "recording"}};
}

QList<Recording *> &RecordingModel::recordings()
{
    return m_recordings;
}

QString RecordingModel::nextDefaultRecordingName()
{
    // used names set
    QSet<QString> usedNames;

    for (const auto &rec : qAsConst(m_recordings)) {
        usedNames.insert(rec->fileName());
    }

    // add files in storage location
    QDir storageLocation{QStandardPaths::writableLocation(QStandardPaths::MusicLocation)};
    for (QFileInfo &info : storageLocation.entryInfoList()) {
        auto name = info.fileName();
        auto list = name.split(QStringLiteral("."));

        // insert without file extension
        if (list.size() > 0) {
            usedNames.insert(list[0]);
        }
    }

    // determine valid clip name (ex. clip_0001, clip_0002, etc.)

    int num = 1;
    QString build = QStringLiteral("0001");

    while (usedNames.contains(DEF_RECORD_PREFIX + QStringLiteral("_") + build)) {
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

    beginInsertRows(QModelIndex(), 0, 0);

    m_recordings.insert(0, new Recording(this, filePath, fileName, recordDate, recordingLength));
    save();

    endInsertRows();
    Q_EMIT countChanged();
}

void RecordingModel::deleteRecording(const int index)
{
    qDebug() << "Removing recording " << m_recordings[index]->filePath();

    beginRemoveRows(QModelIndex(), index, index);

    QFile::remove(m_recordings[index]->filePath());
    m_recordings.removeAt(index);
    save();

    endRemoveRows();
    Q_EMIT countChanged();
}
