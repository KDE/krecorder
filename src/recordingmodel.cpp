#include "recordingmodel.h"

#include <QFile>
#include <QStandardPaths>
#include <QJsonObject>

#include "utils.h"
#include <QDebug>


RecordingModel::RecordingModel(QObject *parent) : QAbstractListModel(parent)
{
    m_settings = new QSettings(parent);
    m_recordings = m_settings->value(QStringLiteral("recordings")).toList();
}

RecordingModel::~RecordingModel()
{
    m_settings->setValue(QStringLiteral("recordings"), m_recordings);
    delete m_settings;
}

QVariant RecordingModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_recordings.count()) {
        return {};
    }

    switch(role) {
    case Roles::RecordingTimeRole:
        return Utils::formatDateTime(m_recordings[index.row()].toHash().value(QLatin1String("recordingTime")).toString());
    case Roles::FileNameRole:
        return m_recordings[index.row()].toHash().value(QLatin1String("fileName")).toString();
    case Roles::DurationRole:
        return m_recordings[index.row()].toHash().value(QLatin1String("duration")).toString();
    }

    return {};
}

QHash<int, QByteArray> RecordingModel::roleNames() const
{
    QHash<int, QByteArray> roleNames;
    roleNames[Roles::RecordingTimeRole] = QByteArray("recordingTime");
    roleNames[Roles::FileNameRole] = QByteArray("fileName");
    roleNames[Roles::DurationRole] = QByteArray("duration");

    return roleNames;
}

int RecordingModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_recordings.count();
}

void RecordingModel::insertRecording(const QJsonObject &recording)
{
    beginInsertRows({}, m_recordings.count(), m_recordings.count());
    m_recordings.append(recording.toVariantHash());

    qDebug() << recording.toVariantHash().value("fileName");
    endInsertRows();
}

void RecordingModel::deleteRecording(const int index)
{
    QFile::remove(m_recordings[index].toHash().value(QStringLiteral("fileName")).toString());
    beginRemoveRows({}, index, index);
    m_recordings.removeAt(index);
    endRemoveRows();
}

