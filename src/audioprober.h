/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef AUDIOPROBER_H
#define AUDIOPROBER_H

#include <QAudioProbe>
#include <QObject>
#include <QTimer>
#include <QVariant>
#include <QAudioRecorder>
#include <QMediaPlayer>
#include <QDebug>

class AudioProber : public QAudioProbe
{
    Q_OBJECT
    Q_PROPERTY(QVariantList volumesList READ volumesList NOTIFY volumesListChanged)
    Q_PROPERTY(int animationIndex READ animationIndex NOTIFY animationIndexChanged)
    Q_PROPERTY(int maxVolumes READ maxVolumes WRITE setMaxVolumes NOTIFY maxVolumesChanged)

public:
    AudioProber(QObject *parent = nullptr) {}
    AudioProber(QObject *parent, QAudioRecorder *source);
    AudioProber(QObject *parent, QMediaPlayer *source);

    void process(QAudioBuffer buffer);
    void processVolumeBar();

    QVariantList volumesList() const
    {
        return m_volumesList;
    }

    int maxVolumes()
    {
        return m_maxVolumes;
    }

    void setMaxVolumes(int m)
    {
        m_maxVolumes = m;
        Q_EMIT maxVolumesChanged();
    }

    int animationIndex()
    {
        return m_animationIndex;
    }

    void clearVolumesList()
    {
        while (!m_volumesList.empty())
            m_volumesList.removeFirst();
        Q_EMIT volumesListChanged();
        Q_EMIT volumesListCleared();
    }

private:
    void handleRecorderState(QAudioRecorder::State state);
    void handlePlayerState(QMediaPlayer::State state);
    
    int m_audioSum = 0;  //
    int m_audioLen = 0; // used for calculating the value of one volume bar from many
    int m_animationIndex = 0; // which index rectangle is being expanded
    int m_maxVolumes = 100; // based on width of screen

    QVariantList m_volumesList;

    QTimer *volumeBarTimer;
    QAudioRecorder *m_recorderSource;
    QMediaPlayer *m_playerSource;
    
signals:
    void volumesListAdded(int volume);
    void volumesListChanged();
    void animationIndexChanged();
    void maxVolumesChanged();
    void volumesListCleared();
};

#endif
