/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audioprober.h"

AudioProber::AudioProber(QObject *parent, QAudioRecorder *source) : QAudioProbe(parent)
{
    m_recorderSource = source;
    connect(this, &AudioProber::audioBufferProbed, this, &AudioProber::process);
    
    // connect to recorder
    connect(m_recorderSource, &QAudioRecorder::stateChanged, this, &AudioProber::handleRecorderState);
    
    // loop to add volume bars 
    volumeBarTimer = new QTimer(this);
    connect(volumeBarTimer, &QTimer::timeout, this, &AudioProber::processVolumeBar);
    volumeBarTimer->setInterval(150);
}

AudioProber::AudioProber(QObject *parent, QMediaPlayer *source) : QAudioProbe(parent)
{
    m_playerSource = source;
    connect(this, &AudioProber::audioBufferProbed, this, &AudioProber::process);
    
    // connect to player
    connect(m_playerSource, &QMediaPlayer::stateChanged, this, &AudioProber::handlePlayerState);
    
    // loop to add volume bars 
    volumeBarTimer = new QTimer(this);
    connect(volumeBarTimer, &QTimer::timeout, this, &AudioProber::processVolumeBar);
    volumeBarTimer->setInterval(150);
}

void AudioProber::handleRecorderState(QAudioRecorder::State state) {
    if (state == QAudioRecorder::RecordingState) {
        volumeBarTimer->start();
    } else if (state == QAudioRecorder::PausedState) {
        volumeBarTimer->stop();
    } else if (state == QAudioRecorder::StoppedState) {
        volumeBarTimer->stop();
        // clear volumes list
        clearVolumesList();
    }
}

void AudioProber::handlePlayerState(QMediaPlayer::State state) {
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

void AudioProber::processVolumeBar() 
{
    if (isActive()) {
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

void AudioProber::process(QAudioBuffer buffer) 
{
    int sum = 0;
    for (int i = 0; i < buffer.sampleCount(); i++) {
        sum += abs(static_cast<short *>(buffer.data())[i]);
    }

    sum /= buffer.sampleCount();
    
    m_audioSum += sum;
    m_audioLen++;
}
