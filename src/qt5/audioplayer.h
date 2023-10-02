/*
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QMediaPlayer>
#include <QAudioProbe>
#include <QQmlEngine>
#include <QUrl>
#include <QCoreApplication>

#include <audioprober.h>

class AudioPlayer : public QMediaPlayer
{
    Q_OBJECT
    Q_PROPERTY(AudioProber *prober READ prober CONSTANT)

public:
    static AudioPlayer *instance();

    void handleStateChange(QMediaPlayer::State state);

    AudioProber *prober();

    Q_INVOKABLE void setMediaPath(QString path);

private:
    explicit AudioPlayer(QObject *parent = nullptr);

    AudioProber *m_audioProbe;
    
    bool wasStopped = false;
};
