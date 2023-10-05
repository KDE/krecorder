/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audiorecorder.h"

#include <QAudioDevice>
#include <QCoreApplication>
#include <QFileInfo>
#include <QMediaDevices>
#include <QMediaFormat>
#include <QStandardPaths>
#include <QQmlEngine>

#include "recordingmodel.h"

#include <QDebug>

AudioRecorder *AudioRecorder::instance()
{
    static AudioRecorder *s_audioRecorder = new AudioRecorder(qApp);
    return s_audioRecorder;
}

AudioProber *AudioRecorder::prober()
{
    return m_audioProbe;
}

AudioRecorder::AudioRecorder(QObject *parent) : QMediaRecorder(parent)
{
    setQuality(QMediaRecorder::HighQuality);
    setEncodingMode(QMediaRecorder::ConstantQualityEncoding);
    // setAudioBitRate(0);
    // setAudioChannelCount(-1);
    // setMediaFormat(QMediaFormat(QMediaFormat::UnspecifiedFormat));

    m_audioProbe = new AudioProber(parent, this);
    m_audioProbe->setSource(actualLocation());

    m_mediaCaptureSession = new QMediaCaptureSession(this);
    m_audioInput = new QAudioInput(QMediaDevices::defaultAudioInput(), this);
    m_mediaCaptureSession->setAudioInput(m_audioInput);
    m_mediaCaptureSession->setRecorder(this);

    QQmlEngine::setObjectOwnership(m_audioProbe, QQmlEngine::CppOwnership);

    // once the file is done writing, save recording to model
    connect(this, &QMediaRecorder::recorderStateChanged, this, &AudioRecorder::handleStateChange);
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

void AudioRecorder::handleStateChange(RecorderState state)
{
    if (state == QMediaRecorder::StoppedState) {
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
        
    } else if (state == QMediaRecorder::PausedState) {
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
