#include "audiorecorder.h"

constexpr int MAX_VOLUME = 1000;
constexpr int MAX_DATA_COUNT = 300;

AudioRecorder::AudioRecorder(QObject *parent) : QAudioRecorder(parent)
{
    m_audioProbe = new QAudioProbe(parent);
    connect(m_audioProbe, &QAudioProbe::audioBufferProbed, this, &AudioRecorder::process);

    m_audioProbe->setSource(this);

    for (int n = 0; n < MAX_DATA_COUNT; ++n) {
        m_volumesList.append(0);
    }
}

void AudioRecorder::process(QAudioBuffer buffer) {
    m_probeN++;
    int sum = 0;
    for (int i = 0; i < buffer.sampleCount(); i++) {
        sum += abs(static_cast<short *>(buffer.data())[i]);
    }
    sum /= buffer.sampleCount();
    if (sum > MAX_VOLUME) {
        m_volumesList.append(MAX_VOLUME);
    } else {
        m_volumesList.append(sum);
    }

    if (m_volumesList.count() > MAX_DATA_COUNT) {
        m_volumesList.removeFirst();
    }
    volumesListChanged();
}

QVariantList AudioRecorder::volumesList() const
{
    return {m_volumesList.begin(), m_volumesList.end()};
}
