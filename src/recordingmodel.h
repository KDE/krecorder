/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
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
    explicit Recording(QObject *parent, const QJsonObject &obj);
    
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

class RecordingModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<Recording *> recordings READ recordings NOTIFY recordingsChanged)

public:
    static RecordingModel* instance()
    {
        static RecordingModel *recordingModel = nullptr;
        if (!recordingModel) {
            recordingModel = new RecordingModel(qApp);
        }
        return recordingModel;
    }
    
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

#endif // RECORDINGMODEL_H
