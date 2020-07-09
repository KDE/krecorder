#include "settingsmodel.h"

SettingsModel::SettingsModel(QObject *parent) : 
    QObject(parent)
{
    settings = new QSettings();
    
    setAudioCodec(audioCodec());
    setContainerFormat(containerFormat());
    setAudioQuality(audioQuality());
}

SettingsModel::~SettingsModel()
{
    delete settings;
}

int SettingsModel::simpleAudioFormat() const
{
    SimpleAudioFormat format = SimpleAudioFormat::OTHER;
    for (auto p : formatMap.keys()) {
        if (formatMap[p].first == audioCodec() && formatMap[p].second == containerFormat()) {
            format = p;
            break;
        }
    }
    return format;
}

void SettingsModel::setSimpleAudioFormat(int audioFormat)
{
    SimpleAudioFormat format = static_cast<SimpleAudioFormat>(audioFormat);
    setAudioCodec(formatMap[format].first);
    setContainerFormat(formatMap[format].second);
}

QString SettingsModel::audioCodec() const
{
    return settings->value("General/audioCodec", "audio/x-vorbis").toString();
}

void SettingsModel::setAudioCodec(QString audioCodec)
{
    AudioRecorder::inst()->setAudioCodec(audioCodec);
    settings->setValue("General/audioCodec", audioCodec);
    
    emit audioCodecChanged();
    emit simpleAudioFormatChanged();
}

QString SettingsModel::containerFormat() const
{
    return settings->value("General/containerFormat", "audio/ogg").toString();
}

void SettingsModel::setContainerFormat(QString audioContainerFormat)
{
    AudioRecorder::inst()->setContainerFormat(audioContainerFormat);
    settings->setValue("General/containerFormat", audioContainerFormat);
    
    emit containerFormatChanged();
    emit simpleAudioFormatChanged();
}

int SettingsModel::audioQuality() const
{
    return settings->value("General/audioQuality", 3).toInt();
}

void SettingsModel::setAudioQuality(int audioQuality)
{
    QAudioEncoderSettings s = AudioRecorder::inst()->audioSettings();
    s.setQuality(static_cast<QMultimedia::EncodingQuality>(audioQuality));
    AudioRecorder::inst()->setAudioSettings(s);
    
    settings->setValue("General/audioQuality", audioQuality);
    
    emit audioQualityChanged();
}
