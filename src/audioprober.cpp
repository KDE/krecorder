/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QAudioFormat>
#include <QAudioInput>
#include <QMediaCaptureSession>

#include "audioprober.h"

AudioProber::AudioProber(QObject *parent)
    : QAudioDecoder{parent}
{
}

AudioProber::AudioProber(QObject *parent, QMediaRecorder *source)
    : QAudioDecoder{parent}
    , m_recorderSource{source}
{
    QAudioFormat format;
    // Set up the desired format, for example:
    format.setSampleRate(8000);
    format.setChannelCount(1);
    format.setSampleFormat(QAudioFormat::UInt8);

    QAudioDevice device = source->captureSession()->audioInput()->device();
    if (!device.isFormatSupported(format)) {
        qWarning() << "Default format not supported, trying to use the nearest.";
    }

    m_audioSource = new QAudioSource(device, format, this);

    // connect to recorder
    connect(m_recorderSource, &QMediaRecorder::recorderStateChanged, this, &AudioProber::handleRecorderState);

    // loop to add volume bars
    volumeBarTimer = new QTimer(this);
    connect(volumeBarTimer, &QTimer::timeout, this, &AudioProber::processVolumeBar);
    volumeBarTimer->setInterval(150);
}

AudioProber::AudioProber(QObject *parent, QMediaPlayer *source)
    : QAudioDecoder{parent}
    , m_playerSource{source}
{
    connect(this, &AudioProber::bufferReady, this, &AudioProber::process);

    // connect to player
    connect(m_playerSource, &QMediaPlayer::playbackStateChanged, this, &AudioProber::handlePlayerState);

    // loop to add volume bars
    volumeBarTimer = new QTimer(this);
    connect(volumeBarTimer, &QTimer::timeout, this, &AudioProber::processVolumeBar);
    volumeBarTimer->setInterval(150);
}

void AudioProber::handleRecorderState(QMediaRecorder::RecorderState state)
{
    if (state == QMediaRecorder::RecordingState) {
        start();
        volumeBarTimer->start();
    } else if (state == QMediaRecorder::PausedState) {
        stop();
        volumeBarTimer->stop();
    } else if (state == QMediaRecorder::StoppedState) {
        stop();
        volumeBarTimer->stop();
        // clear volumes list
        clearVolumesList();
    }
}

void AudioProber::handlePlayerState(QMediaPlayer::PlaybackState state)
{
    if (state == QMediaPlayer::PlayingState) {
        volumeBarTimer->start();
    } else if (state == QMediaPlayer::PausedState) {
        volumeBarTimer->stop();
    } else if (state == QMediaPlayer::StoppedState) {
        volumeBarTimer->stop();
        // clear volumes list
        clearVolumesList();
    }
}

void AudioProber::start()
{
    qDebug() << "pang";
    QIODevice *iodevice = m_audioSource->start();
    qDebug() << iodevice;
    setSourceDevice(iodevice);
    qDebug() << sourceDevice();
    QAudioDecoder::start();
    connect(this, &QAudioDecoder::bufferReady, this, &AudioProber::process);
}

void AudioProber::processVolumeBar()
{
    if (isDecoding()) {
        // m_audioLen might be 0
        const int val = m_audioLen == 0 ? 0 : m_audioSum / m_audioLen;

        m_volumesList.append(val);
        Q_EMIT volumesListAdded(val);

        if (m_volumesList.count() > m_maxVolumes) {
            m_volumesList.removeFirst();
        }

        Q_EMIT volumesListChanged();

        // index of rectangle to animate
        if (m_volumesList.count() != 0) {
            m_animationIndex = m_volumesList.count();
            Q_EMIT animationIndexChanged();
        }

        m_audioSum = 0;
        m_audioLen = 0;
    }
}

void AudioProber::process()
{
    qDebug() << "ping";
    int sum = 0;
    auto buffer = read();
    for (int i = 0; i < buffer.sampleCount(); i++) {
        const short *bufferData = buffer.data<short>();
        sum += abs(bufferData[i]);
    }

    sum /= read().sampleCount();

    m_audioSum += sum;
    m_audioLen++;
}

QVariantList AudioProber::volumesList() const
{
    return m_volumesList;
}

int AudioProber::maxVolumes()
{
    return m_maxVolumes;
}

void AudioProber::setMaxVolumes(int m)
{
    m_maxVolumes = m;
    Q_EMIT maxVolumesChanged();
}

int AudioProber::animationIndex()
{
    return m_animationIndex;
}

void AudioProber::clearVolumesList()
{
    while (!m_volumesList.empty())
        m_volumesList.removeFirst();
    Q_EMIT volumesListChanged();
    Q_EMIT volumesListCleared();
}
