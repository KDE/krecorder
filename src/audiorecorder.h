/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QAudioInput>
#include <QMediaCaptureSession>
#include <QMediaRecorder>

#include "audioprober.h"

class AudioRecorder : public QMediaRecorder
{
    Q_OBJECT
    Q_PROPERTY(QString storageFolder READ storageFolder CONSTANT)
    Q_PROPERTY(AudioProber* prober READ prober CONSTANT)
    
private:
    explicit AudioRecorder(QObject *parent = nullptr);
    void handleStateChange(QMediaRecorder::RecorderState state);

    AudioProber *m_audioProbe;
    QMediaCaptureSession *m_mediaCaptureSession;
    QAudioInput *m_audioInput;

    QString recordingName = {}; // rename recording after recording finishes
    QString savedPath = {}; // updated after the audio file is renamed
    int cachedDuration = 0; // cache duration (since it is set to zero when the recorder is in StoppedState)
    bool resetRequest = false;
    
public:
    static AudioRecorder* instance();

    AudioProber* prober();
    
    QString storageFolder() const;
    
    Q_INVOKABLE void reset();
    
    Q_INVOKABLE void saveRecording();

    void renameCurrentRecording();
    Q_INVOKABLE void setRecordingName(const QString &rName);

Q_SIGNALS:
    void audioCodecChanged();
    void audioQualityChanged();
};
