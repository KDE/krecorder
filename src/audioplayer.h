#ifndef AUDIOPLAYER_H
#define AUDIOPLAYER_H

#include <QMediaPlayer>
#include <QAudioProbe>
#include <QQmlEngine>
#include <QUrl>

#include <audioprober.h>

class AudioPlayer;
static AudioPlayer *s_audioPlayer;

class AudioPlayer : public QMediaPlayer
{
    Q_OBJECT
    Q_PROPERTY(AudioProber *prober READ prober CONSTANT)
    
public:
    explicit AudioPlayer(QObject *parent = nullptr);
    
    static void init()
    {
        s_audioPlayer = new AudioPlayer();
    }
    
    static AudioPlayer *inst()
    {
        return s_audioPlayer;
    }
    
    void handleStateChange(QMediaPlayer::State state);
    
    AudioProber *prober()
    {
        return m_audioProbe;
    }
    
    Q_INVOKABLE void setMediaPath(QString path)
    {
        setMedia(QUrl::fromLocalFile(path));
    }
    
private:
    AudioProber *m_audioProbe;
    
    bool wasStopped = false;
};

#endif
