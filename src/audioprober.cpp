#include "audioprober.h"

constexpr int MAX_VOLUME = 1000;

AudioProber::AudioProber(QObject *parent) : QAudioProbe(parent)
{
    connect(this, &AudioProber::audioBufferProbed, this, &AudioProber::process);
    m_volumesList.append(0);
    
    // loop to add volume bars 
    volumeBarTimer = new QTimer(this);
    connect(volumeBarTimer, &QTimer::timeout, this, &AudioProber::processVolumeBar);
    volumeBarTimer->start(150);
}

void AudioProber::processVolumeBar() 
{
    if (m_audioLen != 0) {
        int val = m_audioSum / m_audioLen;
        
        m_volumesList.append(val);

        if (m_volumesList.count() > m_maxVolumes) {
            m_volumesList.removeFirst();
        }
        
        // remove volume if it is zero
        while (m_volumesList.size() > 0 && m_volumesList[0] == 0)
            m_volumesList.removeFirst();
            
        emit volumesListChanged();
        
        // index of rectangle to animate
        if (m_volumesList.count() != 0) {
            m_animationIndex = m_volumesList.count();
            emit animationIndexChanged();
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
    
    if (sum > MAX_VOLUME)
        sum = MAX_VOLUME;
    
    m_audioSum += sum;
    m_audioLen++;
}
