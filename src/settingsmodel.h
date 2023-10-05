/*
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QObject>
#include <QString>
#include <QCoreApplication>
#include <QSettings>
#include <QQuickItem>

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
    Q_ENUM(SimpleAudioFormat)

    const QMap<SimpleAudioFormat, std::pair<QString, QString>> formatMap = {
        {SimpleAudioFormat::VORBIS, {QStringLiteral("audio/x-vorbis"), QStringLiteral("audio/ogg")}},
        {SimpleAudioFormat::OPUS, {QStringLiteral("audio/x-opus"), QStringLiteral("audio/ogg")}},
        {SimpleAudioFormat::FLAC, {QStringLiteral("audio/x-flac"), QStringLiteral("audio/ogg")}},
        {SimpleAudioFormat::MP3, {QStringLiteral("audio/mpeg, mpegversion=(int)4"), QStringLiteral("audio/mpeg, mpegversion=(int)1")}},
        {SimpleAudioFormat::WAV, {QStringLiteral("audio/x-raw"), QStringLiteral("audio/x-wav")}},
        {SimpleAudioFormat::OTHER, {QString(), QString()}}
    };

    static SettingsModel* instance();

    int simpleAudioFormat() const;
    void setSimpleAudioFormat(int audioFormat);

    QString audioCodec() const;
    void setAudioCodec(const QString &audioCodec);

    QString audioInput() const;
    void setAudioInput(const QString &audioInput);

    QString containerFormat() const;
    void setContainerFormat(const QString &audioContainerFormat);

    int audioQuality() const;
    void setAudioQuality(int audioQuality);

private:
    explicit SettingsModel(QObject *parent = nullptr);
    ~SettingsModel();

    QSettings *settings;

Q_SIGNALS:
    void simpleAudioFormatChanged();
    void audioCodecChanged();
    void containerFormatChanged();
    void audioQualityChanged();
};
