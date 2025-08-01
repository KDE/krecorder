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
    Q_PROPERTY(QString audioInput READ audioInput NOTIFY audioInputChanged)
    Q_PROPERTY(QVariantList supportedAudioCodecs READ supportedAudioCodecs CONSTANT)
    Q_PROPERTY(QVariantList supportedContainers READ supportedContainers CONSTANT)
    Q_PROPERTY(QString audioCodec READ audioCodec WRITE setAudioCodec NOTIFY audioCodecChanged)
    Q_PROPERTY(int audioQuality READ audioQuality WRITE setAudioQuality NOTIFY audioQualityChanged)
    Q_PROPERTY(QString containerFormat READ containerFormat WRITE setContainerFormat)
    Q_PROPERTY(QString storageFolder READ storageFolder CONSTANT)
    // Q_PROPERTY(AudioProber* prober READ prober CONSTANT)

private:
    explicit AudioRecorder(QObject *parent = nullptr);
    void handleStateChange(QMediaRecorder::RecorderState state);
    void updateFormats(QMediaFormat::FileFormat fileFormat = QMediaFormat::FileFormat::UnspecifiedFormat,
                       QMediaFormat::AudioCodec audioCodec = QMediaFormat::AudioCodec::Unspecified);
    void updateAudioInputs();

    QMediaFormat *m_mediaFormat;
    QMediaCaptureSession *m_mediaCaptureSession;
    QAudioInput *m_audioInput;

    // AudioProber *m_audioProbe;

    QString m_recordingName = {}; // rename recording after recording finishes
    QString m_savedPath = {}; // updated after the audio file is renamed
    int m_cachedDuration = 0; // cache duration (since it is set to zero when the recorder is in StoppedState)
    bool m_resetRequest = false;

    QString m_containerFormat;

    QVariantList m_supportedAudioCodecs;
    QVariantList m_supportedContainers;

    bool m_updatingFormats = false;
    void slotContainerFormatChanged();
    void slotAudioCodecChanged();
    void slotAudioQualityChanged();

public:
    static AudioRecorder *instance();

    // AudioProber* prober();

    QString audioInput();
    Q_INVOKABLE void setAudioInput(QAudioDevice device);

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

    QVariantList supportedAudioCodecs() const;
    QVariantList supportedContainers() const;

Q_SIGNALS:
    void audioInputChanged();
    void audioCodecChanged();
    void audioQualityChanged();
};
