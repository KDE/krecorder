#include "audiorecorder.h"

#include <QDebug>
#include <complex>
#include <iostream>

AudioRecorder::AudioRecorder(QObject *parent) : QAudioRecorder(parent)
{
    m_audioProbe = new QAudioProbe();
    connect(m_audioProbe, &QAudioProbe::audioBufferProbed, this, &AudioRecorder::process);

    m_audioProbe->setSource(this);
}

void AudioRecorder::process(QAudioBuffer buffer) {
    m_probeN++;
    int sum = 0;
    for(int i = 0; i < buffer.sampleCount(); i++) {
        sum += abs(static_cast<short *>(buffer.data())[i]);
    }
    sum/=buffer.sampleCount();

    m_volumesList.append(sum);
    volumesListChanged();
}

QList<int> AudioRecorder::volumesList() const
{
    return m_volumesList;
}
