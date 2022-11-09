/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audiorecorder.h"

AudioRecorder* AudioRecorder::instance()
{
    static AudioRecorder *s_audioRecorder = new AudioRecorder(qApp);
    return s_audioRecorder;
}

AudioRecorder::AudioRecorder(QObject *parent) : QAudioRecorder(parent)
{
    m_audioProbe = new AudioProber(parent, this);
    m_audioProbe->setSource(this);
    
    QQmlEngine::setObjectOwnership(m_audioProbe, QQmlEngine::CppOwnership);

    // once the file is done writing, save recording to model
    connect(this, &QAudioRecorder::stateChanged, this, &AudioRecorder::handleStateChange);
}

AudioProber* AudioRecorder::prober()
{
    return m_audioProbe;
}
    
QString AudioRecorder::audioCodec() 
{
    return m_encoderSettings.codec();
}

void AudioRecorder::setAudioCodec(const QString &codec)
{
    m_encoderSettings.setCodec(codec);
    setAudioSettings(m_encoderSettings);
    Q_EMIT audioCodecChanged();
}

int AudioRecorder::audioQuality() 
{
    return m_encoderSettings.quality();
}

void AudioRecorder::setAudioQuality(int quality)
{
    m_encoderSettings.setQuality(QMultimedia::EncodingQuality(quality));
    setAudioSettings(m_encoderSettings);
    Q_EMIT audioQualityChanged();
}

QString AudioRecorder::storageFolder() const
{
    return QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
}

void AudioRecorder::reset()
{
    resetRequest = true;
    stop();
}

void AudioRecorder::handleStateChange(QAudioRecorder::State state)
{
    if (state == QAudioRecorder::StoppedState) {
        if (resetRequest) {
            // reset
            resetRequest = false;
            QFile(actualLocation().toString()).remove();
            qDebug() << "Discarded recording " << actualLocation().toString();
            recordingName = QString();
            
        } else {
            // rename file to desired file name
            renameCurrentRecording();
            // create recording
            saveRecording();
        }
        
    } else if (state == QAudioRecorder::PausedState) {
        cachedDuration = duration();
    }
}


void AudioRecorder::renameCurrentRecording()
{
    if (!recordingName.isEmpty()) {
        
        // determine new file name
        QStringList spl = actualLocation().fileName().split(QStringLiteral("."));
        QString suffix = spl.size() > 0 ? QStringLiteral(".") + spl[spl.size()-1] : QString();
        QString path = storageFolder() + QStringLiteral("/") + recordingName;
        QString updatedPath = path + suffix;
        
        // ignore if the file destination is the same as the one currently being written to
        if (actualLocation().path() != updatedPath) {
            // if the file already exists, add a number to the end
            int cur = 1;
            QFileInfo check(updatedPath);
            while (check.exists()) {
                updatedPath = QStringLiteral("%1_%2%3").arg(path, QString::number(cur), suffix);
                check = QFileInfo(updatedPath);
                cur++;
            }
            
            QFile(actualLocation().path()).rename(updatedPath);
        }
     
        savedPath = updatedPath;
        recordingName = QString();
    } else {
        savedPath = actualLocation().path();
    }
}

void AudioRecorder::setRecordingName(const QString &rName) {
    recordingName = rName;
}

void AudioRecorder::saveRecording() 
{
    // get file name from path
    QStringList spl = savedPath.split(QStringLiteral("/"));
    QString fileName = spl.at(spl.size()-1).split(QStringLiteral("."))[0];
    
    RecordingModel::instance()->insertRecording(savedPath, fileName, QDateTime::currentDateTime(), cachedDuration / 1000);
}
