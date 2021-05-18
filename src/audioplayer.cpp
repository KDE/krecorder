/*
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audioplayer.h"

AudioPlayer::AudioPlayer(QObject *parent) : QMediaPlayer(parent)
{
    m_audioProbe = new AudioProber(parent, this);
    m_audioProbe->setSource(this);
    
    QQmlEngine::setObjectOwnership(m_audioProbe, QQmlEngine::CppOwnership);
    
    connect(this, &AudioPlayer::stateChanged, this, &AudioPlayer::handleStateChange);
}

void AudioPlayer::handleStateChange(QMediaPlayer::State state)
{
    if (state == QMediaPlayer::StoppedState) {
        wasStopped = true;
    } else if (state == QMediaPlayer::PlayingState && wasStopped) {
        wasStopped = false;
    }
}


