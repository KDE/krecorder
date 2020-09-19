/*
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef SETTINGSMODEL_H
#define SETTINGSMODEL_H

#include <QObject>
#include <QString>
#include <QMultimedia>
#include <QCoreApplication>

#include <audiorecorder.h>

class SettingsModel;
static SettingsModel *s_settingsModel = nullptr;

class SettingsModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int simpleAudioFormat READ simpleAudioFormat WRITE setSimpleAudioFormat NOTIFY simpleAudioFormatChanged)
    Q_PROPERTY(QString audioCodec READ audioCodec WRITE setAudioCodec NOTIFY audioCodecChanged)
    Q_PROPERTY(QString containerFormat READ containerFormat WRITE setContainerFormat NOTIFY containerFormatChanged)
    Q_PROPERTY(int audioQuality READ audioQuality WRITE setAudioQuality NOTIFY audioQualityChanged)

public:
    enum SimpleAudioFormat {
        VORBIS, // codec: audio/x-vorbis, container: audio/ogg
        OPUS, // codec: audio/x-opus, container: audio/ogg
        FLAC, // codec: audio/x-flac, container: audio/ogg
        MP3, // codec: audio/mpeg, mpegversion=(int)4, container: audio/mpeg, mpegversion=(int)1
        WAV, // codec: audio/x-raw, container: audio/x-wav
        OTHER // not listed here
    };

    const QMap<SimpleAudioFormat, std::pair<QString, QString>> formatMap = {
        {SimpleAudioFormat::VORBIS, {"audio/x-vorbis", "audio/ogg"}},
        {SimpleAudioFormat::OPUS, {"audio/x-opus", "audio/ogg"}},
        {SimpleAudioFormat::FLAC, {"audio/x-flac", "audio/ogg"}},
        {SimpleAudioFormat::MP3, {"audio/mpeg, mpegversion=(int)4", "audio/mpeg, mpegversion=(int)1"}},
        {SimpleAudioFormat::WAV, {"audio/x-raw", "audio/x-wav"}},
        {SimpleAudioFormat::OTHER, {"", ""}}
    };

    static SettingsModel* instance()
    {
        if (!s_settingsModel) {
            s_settingsModel = new SettingsModel(qApp);
        }
        return s_settingsModel;
    }

    int simpleAudioFormat() const;
    void setSimpleAudioFormat(int audioFormat);
    QString audioCodec() const;
    void setAudioCodec(const QString &audioCodec);
    QString containerFormat() const;
    void setContainerFormat(const QString &audioContainerFormat);
    int audioQuality() const;
    void setAudioQuality(int audioQuality);

private:
    explicit SettingsModel(QObject *parent = nullptr);
    ~SettingsModel();

    QSettings *settings;

signals:
    void simpleAudioFormatChanged();
    void audioCodecChanged();
    void containerFormatChanged();
    void audioQualityChanged();
};

#endif //SETTINGSMODEL_H
