#ifndef AUDIORECORDER_H
#define AUDIORECORDER_H

#include <QAudioRecorder>
#include <QAudioProbe>
#include <QAudioEncoderSettings>
#include <QStandardPaths>
#include <QUrl>
#include <QFileInfo>
#include <QTimer>

#include <recordingmodel.h>

class AudioRecorder : public QAudioRecorder
{
    Q_OBJECT
    Q_PROPERTY(QStringList audioInputs READ audioInputs CONSTANT)
    Q_PROPERTY(QStringList supportedAudioCodecs READ supportedAudioCodecs CONSTANT)
    Q_PROPERTY(QStringList supportedContainers READ supportedContainers CONSTANT)
    Q_PROPERTY(QString audioCodec READ audioCodec WRITE setAudioCodec NOTIFY audioCodecChanged)
    Q_PROPERTY(int audioQuality READ audioQuality WRITE setAudioQuality NOTIFY audioQualityChanged)
    Q_PROPERTY(QString containerFormat READ containerFormat WRITE setContainerFormat)

    Q_PROPERTY(QVariantList volumesList READ volumesList NOTIFY volumesListChanged)

private:
    QAudioEncoderSettings m_encoderSettings {};
    QAudioProbe *m_audioProbe;

    void handleStateChange(QAudioRecorder::State state);
    
    void process(QAudioBuffer buffer);
    void processVolumeBar();
    
    int m_audioSum = 0, m_audioLen = 0; // used for calculating the value of one volume bar from many

    QList<int> m_volumesList;
    
    int maxVolumes = 100; // based on width of screen

    QString recordingName = ""; // rename recording after recording finishes
    QString savedPath = ""; // updated after the audio file is renamed
    int cachedDuration = 0; // cache duration (since it is set to zero when the recorder is in StoppedState)
    bool resetRequest = false;
    
    QTimer* volumeBarTimer;
    
public:
    explicit AudioRecorder(QObject *parent = nullptr);

    Q_INVOKABLE void setMaxVolumes(int m)
    {
        maxVolumes = m;
    }
    
    QString audioCodec() 
    {
        return m_encoderSettings.codec();
    }
    void setAudioCodec(const QString &codec) 
    {
        m_encoderSettings.setCodec(codec);
        setAudioSettings(m_encoderSettings);
        emit audioCodecChanged();
    }
    int audioQuality() 
    {
        return m_encoderSettings.quality();
    }
    void setAudioQuality(int quality) 
    {
        m_encoderSettings.setQuality(QMultimedia::EncodingQuality(quality));
        setAudioSettings(m_encoderSettings);
        emit audioQualityChanged();
    }

    QVariantList volumesList() const;
    void setVolumesList(const QList<int> &volumesList);
    
    Q_INVOKABLE void reset()
    {
        resetRequest = true;
        stop();
    }
    
    Q_INVOKABLE void saveRecording();

    void renameCurrentRecording();
    Q_INVOKABLE void setRecordingName(QString recordingName) {
        this->recordingName = recordingName;
    }
    
signals:
    void audioCodecChanged();
    void audioQualityChanged();

    void volumesListChanged();
};

#endif // AUDIORECORDER_H
