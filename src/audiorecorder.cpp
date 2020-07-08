#include "audiorecorder.h"

constexpr int MAX_VOLUME = 1000;

AudioRecorder::AudioRecorder(QObject *parent) : QAudioRecorder(parent)
{
    m_audioProbe = new QAudioProbe(parent);
    connect(m_audioProbe, &QAudioProbe::audioBufferProbed, this, &AudioRecorder::process);

    m_audioProbe->setSource(this);
    m_volumesList.append(0);
    
    // once the file is done writing, save recording to model
    connect(this, &QAudioRecorder::stateChanged, this, &AudioRecorder::handleStateChange);

    // loop to add volume bars 
    volumeBarTimer = new QTimer(this);
    connect(volumeBarTimer, &QTimer::timeout, this, &AudioRecorder::processVolumeBar);
    volumeBarTimer->start(150);
}

void AudioRecorder::handleStateChange(QAudioRecorder::State state)
{
    if (state == QAudioRecorder::StoppedState) {
        if (resetRequest) {
            // reset
            resetRequest = false;
            QFile(actualLocation().fileName()).remove();
            recordingName = "";
            
        } else {
            // rename file to desired file name
            renameCurrentRecording();
            // create recording
            saveRecording();
        }
        
        while (!m_volumesList.empty())
            m_volumesList.removeFirst();
        
    } else if (state == QAudioRecorder::PausedState) {
        cachedDuration = duration();
    }
}


void AudioRecorder::renameCurrentRecording()
{
    if (recordingName != "") {
        
        // determine new file name
        QStringList spl = actualLocation().fileName().split(".");
        QString suffix = spl.size() > 0 ? "." + spl[spl.size()-1] : "";
        QString path = QStandardPaths::writableLocation(QStandardPaths::MusicLocation) + "/" + recordingName;
        QString updatedPath = path + suffix;
        
        // if the file already exists, add a number to the end
        int cur = 1;
        QFileInfo check(path + suffix);
        while (check.exists()) {
            updatedPath = QString("%1-%2.%3").arg(path, QString::number(cur), suffix);
            check = QFileInfo(updatedPath);
            cur++;
        }
        
        QFile(actualLocation().path()).rename(updatedPath);
     
        savedPath = updatedPath;
        recordingName = "";
    } else {
        savedPath = actualLocation().path();
    }
}

void AudioRecorder::processVolumeBar() 
{
    if (m_audioLen != 0) {
        int val = m_audioSum / m_audioLen;
        
        m_volumesList.append(val);

        if (m_volumesList.count() > maxVolumes) {
            m_volumesList.removeFirst();
        }
        
        // remove volume if it is zero
        while (m_volumesList.size() > 0 && m_volumesList[0] == 0)
            m_volumesList.removeFirst();
            
        volumesListChanged();
        
        m_audioSum = 0;
        m_audioLen = 0;
    }
}

void AudioRecorder::process(QAudioBuffer buffer) 
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

QVariantList AudioRecorder::volumesList() const
{
    return {m_volumesList.begin(), m_volumesList.end()};
}

void AudioRecorder::saveRecording() 
{
    QStringList spl = savedPath.split("/");
    QString fileName = spl[spl.size()-1].split(".")[0];
    
    RecordingModel::inst()->insertRecording(savedPath, fileName, QDateTime::currentDateTime(), cachedDuration / 1000);
}
