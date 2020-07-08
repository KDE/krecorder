#ifndef RECORDINGMODEL_H
#define RECORDINGMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSettings>
#include <QFile>
#include <QJsonObject>

class RecordingModel;

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
    
    QJsonObject toJson();
    
    QString filePath() 
    {
        return m_filePath;
    }
    QString fileName()
    {
        return m_fileName;
    }
    QDateTime recordDate() 
    {
        return m_recordDate;
    }
    QString recordDatePretty()
    {
        return m_recordDate.toString("yyyy-MM-dd");
    }
    int recordingLength() 
    {
        return m_recordingLength;
    }
    QString recordingLengthPretty()
    {
        int hours = m_recordingLength / 60 / 60;
        int min = m_recordingLength / 60 - hours * 60;
        int sec = m_recordingLength - min * 60 - hours * 60 * 60;
        return QString("%1:%2:%3").arg(hours, 2, 10, QLatin1Char('0')).arg(min, 2, 10, QLatin1Char('0')).arg(sec, 2, 10, QLatin1Char('0'));
    }
    
    void setFilePath(QString filePath)
    {
        QFile(m_filePath).rename(filePath);
        m_filePath = filePath;
        
        QStringList spl = filePath.split("/");
        m_fileName = spl[spl.size()-1].split(".")[0];
        
        emit propertyChanged();
    }
    void setFileName(QString fileName)
    {
        QString oldPath = m_filePath;

        m_filePath.replace(QRegExp(m_fileName + "(?!.*" + m_fileName + ")"), fileName);
        QFile(oldPath).rename(m_filePath);

        m_fileName = fileName;        
        emit propertyChanged();
    }
    void setRecordDate(QDateTime date)
    {
        m_recordDate = date;
        emit propertyChanged();
    }
    void setRecordingLength(int recordingLength)
    {
        m_recordingLength = recordingLength;
        emit propertyChanged();
    }
    
private:
    QString m_filePath, m_fileName;
    QDateTime m_recordDate;
    int m_recordingLength; // seconds
    
signals:
    void propertyChanged();
};

static RecordingModel* recordingModel_;

class RecordingModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit RecordingModel(QObject *parent = nullptr);
    ~RecordingModel();
    
    static void init()
    {
        recordingModel_ = new RecordingModel();
    }
    static RecordingModel* inst()
    {
        return recordingModel_;
    }
    
    void load();
    void save();

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Q_INVOKABLE Recording* at(int index);
    Q_INVOKABLE void insertRecording(QString filePath, QString fileName, QDateTime recordDate, int recordingLength);
    Q_INVOKABLE void deleteRecording(const int index);

signals:

private:
    QSettings* m_settings;
    QList<Recording*> m_recordings;
};

#endif // RECORDINGMODEL_H
