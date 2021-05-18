/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audiorecorder.h"

AudioRecorder::AudioRecorder(QObject *parent) : QAudioRecorder(parent)
{
    m_audioProbe = new AudioProber(parent, this);
    m_audioProbe->setSource(this);
    
    QQmlEngine::setObjectOwnership(m_audioProbe, QQmlEngine::CppOwnership);

    // once the file is done writing, save recording to model
    connect(this, &QAudioRecorder::stateChanged, this, &AudioRecorder::handleStateChange);
}

void AudioRecorder::setAudioCodec(const QString &codec)
{
    m_encoderSettings.setCodec(codec);
    setAudioSettings(m_encoderSettings);
    emit audioCodecChanged();
}

void AudioRecorder::setAudioQuality(int quality)
{
    m_encoderSettings.setQuality(QMultimedia::EncodingQuality(quality));
    setAudioSettings(m_encoderSettings);
    emit audioQualityChanged();
}

void AudioRecorder::handleStateChange(QAudioRecorder::State state)
{
    if (state == QAudioRecorder::StoppedState) {
        if (resetRequest) {
            // reset
            resetRequest = false;
            QFile(actualLocation().toString()).remove();
            qDebug() << "Discarded recording " << actualLocation().toString();
            recordingName = "";
            
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
        QStringList spl = actualLocation().fileName().split(".");
        QString suffix = spl.size() > 0 ? "." + spl[spl.size()-1] : "";
        QString path = QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + "/" + recordingName;
        QString updatedPath = path + suffix;
        
        // ignore if the file destination is the same as the one currently being written to
        if (actualLocation().path() != updatedPath) {
            // if the file already exists, add a number to the end
            int cur = 1;
            QFileInfo check(updatedPath);
            while (check.exists()) {
                updatedPath = QString("%1_%2%3").arg(path, QString::number(cur), suffix);
                check = QFileInfo(updatedPath);
                cur++;
            }
            
            QFile(actualLocation().path()).rename(updatedPath);
        }
     
        savedPath = updatedPath;
        recordingName = "";
    } else {
        savedPath = actualLocation().path();
    }
}

void AudioRecorder::saveRecording() 
{
    // get file name from path
    QStringList spl = savedPath.split("/");
    QString fileName = spl.at(spl.size()-1).split(".")[0];
    
    RecordingModel::instance()->insertRecording(savedPath, fileName, QDateTime::currentDateTime(), cachedDuration / 1000);
}
