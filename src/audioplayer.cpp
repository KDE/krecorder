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
{
    m_audioOutput = new QAudioOutput(this);
    setAudioOutput(m_audioOutput);
    connect(this, &AudioPlayer::playbackStateChanged, this, &AudioPlayer::handleStateChange);
}

void AudioPlayer::handleStateChange(PlaybackState state)
{
    if (state == QMediaPlayer::StoppedState) {
        wasStopped = true;
    } else if (state == QMediaPlayer::PlayingState) {
        wasStopped = false;
    }
}

void AudioPlayer::setMediaPath(QString path)
{
    setSource(QUrl::fromLocalFile(path));
}

void AudioPlayer::setVolume(float volume)
{
    m_audioOutput->setVolume(volume);
}
