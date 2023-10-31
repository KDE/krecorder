/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QAudioInput>
#include <QMediaCaptureSession>
#include <QMediaFormat>
#include <QMediaRecorder>

#include "audioprober.h"

class AudioRecorder : public QMediaRecorder
{
    Q_OBJECT
    Q_PROPERTY(QStringList audioInputs READ audioInputs CONSTANT)
    Q_PROPERTY(QStringList supportedAudioCodecs READ supportedAudioCodecs CONSTANT)
    Q_PROPERTY(QStringList supportedContainers READ supportedContainers CONSTANT)
    Q_PROPERTY(QString audioCodec READ audioCodec WRITE setAudioCodec NOTIFY audioCodecChanged)
    Q_PROPERTY(int audioQuality READ audioQuality WRITE setAudioQuality NOTIFY audioQualityChanged)
    Q_PROPERTY(QString containerFormat READ containerFormat WRITE setContainerFormat)
    Q_PROPERTY(AudioProber* prober READ prober CONSTANT)
    Q_PROPERTY(QString storageFolder READ storageFolder CONSTANT)
    
private:
    explicit AudioRecorder(QObject *parent = nullptr);
    void handleStateChange(QMediaRecorder::RecorderState state);

    QMediaFormat *m_mediaFormat;
    QMediaCaptureSession *m_mediaCaptureSession;
    QAudioInput *m_audioInput;

    AudioProber *m_audioProbe;

    QString recordingName = {}; // rename recording after recording finishes
    QString savedPath = {}; // updated after the audio file is renamed
    int cachedDuration = 0; // cache duration (since it is set to zero when the recorder is in StoppedState)
    bool resetRequest = false;

    QString m_containerFormat;

    QStringList m_audioInputs;

    QStringList m_supportedAudioCodecs;

    QStringList m_supportedContainers;

public:
    static AudioRecorder* instance();

    AudioProber* prober();

    QString audioCodec();
    void setAudioCodec(const QString &codec);

    int audioQuality();
    void setAudioQuality(int quality);
    
    QString storageFolder() const;
    
    Q_INVOKABLE void reset();
    
    Q_INVOKABLE void saveRecording();

    void renameCurrentRecording();
    Q_INVOKABLE void setRecordingName(const QString &rName);

    QString containerFormat() const;
    void setContainerFormat(const QString &newContainerFormat);

    QStringList audioInputs() const;

    QStringList supportedAudioCodecs() const;

    QStringList supportedContainers() const;

Q_SIGNALS:
    void audioCodecChanged();
    void audioQualityChanged();
};
