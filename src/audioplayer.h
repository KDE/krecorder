/*
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QAudioOutput>
#include <QMediaPlayer>
#include <QQmlEngine>
#include <QUrl>
#include <QCoreApplication>

class AudioPlayer : public QMediaPlayer
{
    Q_OBJECT

public:
    static AudioPlayer *instance();

    void handleStateChange(QMediaPlayer::PlaybackState state);

    Q_INVOKABLE void setMediaPath(QString path);
    Q_INVOKABLE void setVolume(float volume);

private:
    explicit AudioPlayer(QObject *parent = nullptr);

    QAudioOutput *m_audioOutput;
    
    bool wasStopped = false;
};
