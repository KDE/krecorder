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
    explicit Recording(QObject *parent = nullptr, QString filePath = "", QString fileName = "", QDateTime recordDate = QDateTime::currentDateTime(), int recordingLength = 0);
    explicit Recording(const QJsonObject &obj);
    ~Recording();
    
    QJsonObject toJson();
    
    QString filePath() 
    {
        return filePath_;
    }
    QString fileName()
    {
        return fileName_;
    }
    QDateTime recordDate() 
    {
        return recordDate_;
    }
    QString recordDatePretty()
    {
        return recordDate_.toString("yyyy-MM-dd");
    }
    int recordingLength() 
    {
        return recordingLength_;
    }
    QString recordingLengthPretty()
    {
        int hours = recordingLength_ / 60 / 60;
        int min = recordingLength_ / 60 - hours * 60;
        int sec = recordingLength_ - min * 60 - hours * 60 * 60;
        return QString("%1:%2:%3").arg(hours, 2, 10, QLatin1Char('0')).arg(min, 2, 10, QLatin1Char('0')).arg(sec, 2, 10, QLatin1Char('0'));
    }
    
    void setFilePath(QString filePath)
    {
        QFile(filePath_).rename(filePath);
        filePath_ = filePath;
        
        QStringList spl = filePath.split("/");
        fileName_ = spl[spl.size()-1].split(".")[0];
        
        emit propertyChanged();
    }
    void setFileName(QString fileName)
    {
        QString oldPath = filePath_;

        filePath_.replace(QRegExp(fileName_ + "(?!.*" + fileName_ + ")"), fileName);
        QFile(oldPath).rename(filePath_);

        fileName_ = fileName;        
        emit propertyChanged();
    }
    void setRecordDate(QDateTime date)
    {
        recordDate_ = date;
        emit propertyChanged();
    }
    void setRecordingLength(int recordingLength)
    {
        recordingLength_ = recordingLength;
        emit propertyChanged();
    }
    
private:
    QString filePath_, fileName_;
    QDateTime recordDate_;
    int recordingLength_; // seconds
    
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
