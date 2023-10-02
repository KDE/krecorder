/*
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audioplayer.h"

AudioPlayer *AudioPlayer::instance()
{
    static AudioPlayer *s_audioPlayer = new AudioPlayer(qApp);
    return s_audioPlayer;
}

AudioPlayer::AudioPlayer(QObject *parent) 
    : QMediaPlayer(parent)
    , m_audioProbe{ new AudioProber(parent, this) }
{
    m_audioProbe->setSource(this);
    
    QQmlEngine::setObjectOwnership(m_audioProbe, QQmlEngine::CppOwnership);
    
    connect(this, &AudioPlayer::stateChanged, this, &AudioPlayer::handleStateChange);
}

void AudioPlayer::handleStateChange(QMediaPlayer::State state)
{
    if (state == QMediaPlayer::StoppedState) {
        wasStopped = true;
    } else if (state == QMediaPlayer::PlayingState) {
        wasStopped = false;
    }
}

AudioProber *AudioPlayer::prober()
{
    return m_audioProbe;
}

void AudioPlayer::setMediaPath(QString path)
{
    setMedia(QUrl::fromLocalFile(path));
}
