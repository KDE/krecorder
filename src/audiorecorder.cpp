#include "audiorecorder.h"

#include <QDebug>
#include <complex>
#include <iostream>

AudioRecorder::AudioRecorder(QObject *parent) : QAudioRecorder(parent)
{
    m_audioProbe = new QAudioProbe(parent);
    connect(m_audioProbe, &QAudioProbe::audioBufferProbed, this, &AudioRecorder::process);

    m_audioProbe->setSource(this);

    for (int n = 0; n < 1000; ++n) {
        m_volumesList.append(0);
    }
}

void AudioRecorder::process(QAudioBuffer buffer) {
    m_probeN++;
    int sum = 0;
    for(int i = 0; i < buffer.sampleCount(); i++) {
        sum += abs(static_cast<short *>(buffer.data())[i]);
    }
    sum /= buffer.sampleCount();
    /*int previous = 0;
    for(int i = 901; i < 1000; i++) {
        previous += m_volumesList[i];
    }
    previous += sum;
    previous /= 100;*/

    /*if (previous > 1000) {
        m_volumesList.append(1000);
    } else {
        m_volumesList.append(previous);
    }*/
    if (sum > 1000) {
        m_volumesList.append(1000);
    } else {
        m_volumesList.append(sum);
    }

    if (m_volumesList.count() > 300) {
        m_volumesList.removeFirst();
    }
    volumesListChanged();
}

QVariantList AudioRecorder::volumesList() const
{
    return QVariantList(m_volumesList.begin(), m_volumesList.end());
}
