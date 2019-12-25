#ifndef AUDIORECORDER_H
#define AUDIORECORDER_H

#include <QAudioRecorder>
#include <QAudioEncoderSettings>

class AudioRecorder : public QAudioRecorder
{
    Q_OBJECT
    Q_PROPERTY(QStringList audioInputs READ audioInputs CONSTANT)
    Q_PROPERTY(QStringList supportedAudioCodecs READ supportedAudioCodecs CONSTANT)
    Q_PROPERTY(QStringList supportedContainers READ supportedContainers CONSTANT)
    Q_PROPERTY(QString audioCodec READ audioCodec WRITE setAudioCodec NOTIFY audioCodecChanged)
    Q_PROPERTY(int audioQuality READ audioQuality WRITE setAudioQuality NOTIFY audioQualityChanged)
    Q_PROPERTY(QString containerFormat READ containerFormat WRITE setContainerFormat)

private:
    QAudioEncoderSettings m_encoderSettings {};

public:
    explicit AudioRecorder(QObject *parent = nullptr);

    QString audioCodec() {
        return m_encoderSettings.codec();
    }
    void setAudioCodec(const QString &codec) {
        m_encoderSettings.setCodec(codec);
        setAudioSettings(m_encoderSettings);
        emit audioCodecChanged();
    }
    int audioQuality() {
        return m_encoderSettings.quality();
    }
    void setAudioQuality(int quality) {
        m_encoderSettings.setQuality(QMultimedia::EncodingQuality(quality));
        setAudioSettings(m_encoderSettings);
        emit audioQualityChanged();
    }

signals:
    void audioCodecChanged();
    void audioQualityChanged();
};

#endif // AUDIORECORDER_H
