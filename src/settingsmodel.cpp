/*
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "settingsmodel.h"

SettingsModel *SettingsModel::instance()
{
    static SettingsModel *s_settingsModel = new SettingsModel(qApp);
    return s_settingsModel;
}

SettingsModel::SettingsModel(QObject *parent)
    : QObject(parent)
{
    settings = new QSettings();
}

SettingsModel::~SettingsModel()
{
    delete settings;
}

int SettingsModel::simpleAudioFormat() const
{
    const auto keys = formatMap.keys();
    auto format_it = std::find_if(keys.begin(), keys.end(), [&](const SimpleAudioFormat p) -> bool {
        return formatMap[p].first == audioCodec() && formatMap[p].second == containerFormat();
    });

    if (format_it == keys.end()) {
        return SimpleAudioFormat::OTHER;
    }

    return *format_it;
}

void SettingsModel::setSimpleAudioFormat(int audioFormat)
{
    if (simpleAudioFormat() == audioFormat) {
        return;
    }

    SimpleAudioFormat format = static_cast<SimpleAudioFormat>(audioFormat);
    setAudioCodec(formatMap[format].first);
    setContainerFormat(formatMap[format].second);
}

QString SettingsModel::audioCodec() const
{
    return settings->value(QStringLiteral("General/audioCodec"), QStringLiteral("audio/x-opus")).toString();
}

void SettingsModel::setAudioCodec(const QString &audioCodec)
{
    settings->setValue(QStringLiteral("General/audioCodec"), audioCodec);

    Q_EMIT audioCodecChanged();
    Q_EMIT simpleAudioFormatChanged();
}

QString SettingsModel::containerFormat() const
{
    qDebug() << "format " << settings->value(QStringLiteral("General/containerFormat"), QStringLiteral("audio/ogg")).toString();
    return settings->value(QStringLiteral("General/containerFormat"), QStringLiteral("audio/ogg")).toString();
}

void SettingsModel::setContainerFormat(const QString &audioContainerFormat)
{
    settings->setValue(QStringLiteral("General/containerFormat"), audioContainerFormat);

    Q_EMIT containerFormatChanged();
    Q_EMIT simpleAudioFormatChanged();
}

int SettingsModel::audioQuality() const
{
    return settings->value(QStringLiteral("General/audioQuality"), 3).toInt();
}

void SettingsModel::setAudioQuality(int audioQuality)
{
    if (this->audioQuality() == audioQuality) {
        return;
    }

    settings->setValue(QStringLiteral("General/audioQuality"), audioQuality);

    Q_EMIT audioQualityChanged();
}
