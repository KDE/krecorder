/*
 * SPDX-FileCopyrightText: 2020-2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "settingsmodel.h"

#include <KWindowEffects>

#include <QQuickWindow>

SettingsModel* SettingsModel::instance()
{
    static SettingsModel *s_settingsModel = new SettingsModel(qApp);
    return s_settingsModel;
}

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
    AudioRecorder::instance()->setAudioCodec(audioCodec);
    settings->setValue(QStringLiteral("General/audioCodec"), audioCodec);

    Q_EMIT audioCodecChanged();
    Q_EMIT simpleAudioFormatChanged();
}

QString SettingsModel::containerFormat() const
{
    return settings->value(QStringLiteral("General/containerFormat"), QStringLiteral("audio/ogg")).toString();
}

void SettingsModel::setContainerFormat(const QString &audioContainerFormat)
{
    AudioRecorder::instance()->setContainerFormat(audioContainerFormat);
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
    QAudioEncoderSettings s = AudioRecorder::instance()->audioSettings();
    s.setQuality(static_cast<QMultimedia::EncodingQuality>(audioQuality));
    AudioRecorder::instance()->setAudioSettings(s);
    
    settings->setValue(QStringLiteral("General/audioQuality"), audioQuality);
    
    Q_EMIT audioQualityChanged();
}

void SettingsModel::setBlur(QQuickItem *item, bool blur)
{
    auto setWindows = [item, blur]() {
        auto reg = QRect(QPoint(0, 0), item->window()->size());
        KWindowEffects::enableBackgroundContrast(item->window(), blur, 1, 1, 1, reg);
        KWindowEffects::enableBlurBehind(item->window(), blur, reg);
    };

    disconnect(item->window(), &QQuickWindow::heightChanged, this, nullptr);
    disconnect(item->window(), &QQuickWindow::widthChanged, this, nullptr);
    connect(item->window(), &QQuickWindow::heightChanged, this, setWindows);
    connect(item->window(), &QQuickWindow::widthChanged, this, setWindows);
    setWindows();
}
