/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef RECORDINGMODEL_H
#define RECORDINGMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSettings>
#include <QFile>
#include <QJsonObject>
#include <QDateTime>
#include <QCoreApplication>

class Recording : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY propertyChanged)
    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY propertyChanged)
    Q_PROPERTY(QString recordDate READ recordDatePretty NOTIFY propertyChanged)
    Q_PROPERTY(QString recordingLength READ recordingLengthPretty NOTIFY propertyChanged)
    
public:
    explicit Recording(QObject *parent = nullptr, const QString &filePath = {}, const QString &fileName = {}, QDateTime recordDate = QDateTime::currentDateTime(), int recordingLength = 0);
    explicit Recording(const QJsonObject &obj);
    ~Recording();
    
    QJsonObject toJson() const;
    
    QString filePath() const
    {
        return m_filePath;
    }
    QString fileName() const
    {
        return m_fileName;
    }
    QDateTime recordDate() const
    {
        return m_recordDate;
    }
    QString recordDatePretty() const
    {
        return m_recordDate.toString("yyyy-MM-dd");
    }
    int recordingLength() const
    {
        return m_recordingLength;
    }
    QString recordingLengthPretty() const;

    void setFilePath(const QString &filePath);
    void setFileName(const QString &fileName);

    void setRecordDate(const QDateTime &date);
    void setRecordingLength(int recordingLength);

private:
    QString m_filePath, m_fileName;
    QDateTime m_recordDate;
    int m_recordingLength; // seconds

signals:
    void propertyChanged();
};

class RecordingModel;
static RecordingModel *s_recordingModel = nullptr;

class RecordingModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        RecordingRole = Qt::UserRole
    };

    static RecordingModel* instance()
    {
        if (!s_recordingModel) {
            s_recordingModel = new RecordingModel(qApp);
        }
        return s_recordingModel;
    }
    
    void load();
    void save();

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Q_INVOKABLE QString nextDefaultRecordingName();
    
    Q_INVOKABLE void insertRecording(QString filePath, QString fileName, QDateTime recordDate, int recordingLength);
    Q_INVOKABLE void deleteRecording(const int index);

private:
    explicit RecordingModel(QObject *parent = nullptr);
    ~RecordingModel();

    QSettings* m_settings;
    QList<Recording*> m_recordings;
};

#endif // RECORDINGMODEL_H
