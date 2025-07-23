/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "audiorecorder.h"

#include <QAudioDevice>
#include <QCoreApplication>
#include <QFileInfo>
#include <QMediaDevices>
#include <QMediaFormat>
#include <QQmlEngine>
#include <QStandardPaths>

#include <KLocalizedString>

#if QT_CONFIG(permissions)
#include <QPermissions>
#endif

#include "recordingmodel.h"
#include "settingsmodel.h"

#include <QDebug>

AudioRecorder *AudioRecorder::instance()
{
    static AudioRecorder *s_audioRecorder = new AudioRecorder(qApp);
    return s_audioRecorder;
}

AudioRecorder::AudioRecorder(QObject *parent)
    : QMediaRecorder(parent)
{
#if QT_CONFIG(permissions)
    QMicrophonePermission microphonePermission;
    switch (qApp->checkPermission(microphonePermission)) {
    case Qt::PermissionStatus::Undetermined:
        qApp->requestPermission(microphonePermission, this, &AudioRecorder::instance);
        return;
    case Qt::PermissionStatus::Denied:
        qWarning("Microphone permission is not granted!");
        return;
    case Qt::PermissionStatus::Granted:
        break;
    }
#endif

    m_mediaFormat = new QMediaFormat();

    updateFormats();

    setQuality(QMediaRecorder::HighQuality);
    setEncodingMode(QMediaRecorder::ConstantQualityEncoding);

    m_audioInput = new QAudioInput(QMediaDevices::defaultAudioInput(), this);
    m_mediaCaptureSession = new QMediaCaptureSession(this);
    m_mediaCaptureSession->setAudioInput(m_audioInput);
    m_mediaCaptureSession->setRecorder(this);

    // m_audioProbe = new AudioProber(parent, this);
    // m_audioProbe->setSource(actualLocation());

    // QQmlEngine::setObjectOwnership(m_audioProbe, QQmlEngine::CppOwnership);

    // once the file is done writing, save recording to model
    connect(this, &QMediaRecorder::recorderStateChanged, this, &AudioRecorder::handleStateChange);

    setAudioCodec(SettingsModel::instance()->audioCodec());
    setContainerFormat(SettingsModel::instance()->containerFormat());
    setAudioQuality(SettingsModel::instance()->audioQuality());
    // setAudioBitRate(0);
    // setAudioChannelCount(-1);
    connect(SettingsModel::instance(), &SettingsModel::containerFormatChanged, this, &AudioRecorder::slotContainerFormatChanged);
    connect(SettingsModel::instance(), &SettingsModel::audioCodecChanged, this, &AudioRecorder::slotAudioCodecChanged);
    connect(SettingsModel::instance(), &SettingsModel::audioQualityChanged, this, &AudioRecorder::slotAudioQualityChanged);
}

// AudioProber *AudioRecorder::prober()
// {
//     return m_audioProbe;
// }

QString AudioRecorder::audioInput()
{
    if (!m_audioInput) {
        return {};
    }
    return QString::fromUtf8(m_audioInput->device().id());
}

void AudioRecorder::setAudioInput(QAudioDevice device)
{
    if (m_audioInput) {
        m_audioInput->deleteLater();
    }
    m_audioInput = new QAudioInput(device, this);
    if (m_mediaCaptureSession) {
        m_mediaCaptureSession->setAudioInput(m_audioInput);
    }

    Q_EMIT audioInputChanged();
}

QString AudioRecorder::audioCodec()
{
    return QVariant::fromValue(m_mediaFormat->audioCodec()).toString();
}

void AudioRecorder::setAudioCodec(const QString &codec)
{
    const QMetaEnum metaEnum = QMetaEnum::fromType<QMediaFormat::AudioCodec>();
    const int value = metaEnum.keyToValue(codec.toUtf8().constData());

    QMediaFormat::AudioCodec audioCodec;

    if (value != -1) {
        audioCodec = static_cast<QMediaFormat::AudioCodec>(value);
    } else {
        audioCodec = QMediaFormat::AudioCodec::Opus;
    }

    qDebug() << Q_FUNC_INFO << audioCodec;
    m_mediaFormat->setAudioCodec(audioCodec);
    setMediaFormat(*m_mediaFormat);
    Q_EMIT audioCodecChanged();
}

int AudioRecorder::audioQuality()
{
    return quality();
}

void AudioRecorder::setAudioQuality(int quality)
{
    setQuality(QVariant(quality).value<QMediaRecorder::Quality>());
    Q_EMIT audioQualityChanged();
}

QString AudioRecorder::storageFolder() const
{
    return QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
}

void AudioRecorder::reset()
{
    m_resetRequest = true;
    stop();
}

void AudioRecorder::handleStateChange(RecorderState state)
{
    if (state == QMediaRecorder::StoppedState) {
        if (m_resetRequest) {
            // reset
            m_resetRequest = false;
            QFile(actualLocation().toString()).remove();
            qDebug() << "Discarded recording " << actualLocation().toString();
            m_recordingName = QString();

        } else {
            // rename file to desired file name
            renameCurrentRecording();
            // create recording
            saveRecording();
        }

    } else if (state == QMediaRecorder::PausedState) {
        m_cachedDuration = duration();
    }
}

void AudioRecorder::updateFormats(QMediaFormat::FileFormat fileFormat, QMediaFormat::AudioCodec audioCodec)
{
    if (m_updatingFormats)
        return;
    m_updatingFormats = true;

    m_mediaFormat->setFileFormat(fileFormat);
    m_mediaFormat->setAudioCodec(audioCodec);

    QVariantMap defaultContainer;
    defaultContainer[QStringLiteral("name")] = QString();
    defaultContainer[QStringLiteral("description")] = QStringLiteral("Default file format");
    m_supportedContainers.append(defaultContainer);

    for (auto container : m_mediaFormat->supportedFileFormats(QMediaFormat::Encode)) {
        QVariantMap item;
        item[QStringLiteral("name")] = QMediaFormat::fileFormatName(container);
        item[QStringLiteral("description")] = QMediaFormat::fileFormatDescription(container);
        m_supportedContainers.append(item);
    }

    setMediaFormat(*m_mediaFormat);

    QVariantMap defaultAudioCodec;
    defaultAudioCodec[QStringLiteral("name")] = QString();
    defaultAudioCodec[QStringLiteral("description")] = QStringLiteral("Default audio codec");
    m_supportedAudioCodecs.append(defaultAudioCodec);

    for (auto codec : m_mediaFormat->supportedAudioCodecs(QMediaFormat::Encode)) {
        QVariantMap item;
        item[QStringLiteral("name")] = QMediaFormat::audioCodecName(codec);
        item[QStringLiteral("description")] = QMediaFormat::audioCodecDescription(codec);
        m_supportedAudioCodecs.append(item);
    }

    m_updatingFormats = false;
}

void AudioRecorder::renameCurrentRecording()
{
    if (!m_recordingName.isEmpty()) {
        // determine new file name
        QStringList spl = actualLocation().fileName().split(QStringLiteral("."));
        QString suffix = spl.size() > 0 ? QStringLiteral(".") + spl[spl.size() - 1] : QString();
        QString path = storageFolder() + QStringLiteral("/") + m_recordingName;
        QString updatedPath = path + suffix;

        // ignore if the file destination is the same as the one currently being written to
        if (actualLocation().path() != updatedPath) {
            // if the file already exists, add a number to the end
            int cur = 1;
            QFileInfo check(updatedPath);
            while (check.exists()) {
                updatedPath = QStringLiteral("%1_%2%3").arg(path, QString::number(cur), suffix);
                check = QFileInfo(updatedPath);
                cur++;
            }

            QFile(actualLocation().path()).rename(updatedPath);
        }

        m_savedPath = updatedPath;
        m_recordingName = QString();
    } else {
        m_savedPath = actualLocation().path();
    }
}

void AudioRecorder::setRecordingName(const QString &rName)
{
    m_recordingName = rName;
}

void AudioRecorder::saveRecording()
{
    // get file name from path
    QStringList spl = m_savedPath.split(QStringLiteral("/"));
    QString fileName = spl.at(spl.size() - 1).split(QStringLiteral("."))[0];

    RecordingModel::instance()->insertRecording(m_savedPath, fileName, QDateTime::currentDateTime(), m_cachedDuration / 1000);
}

QString AudioRecorder::containerFormat() const
{
    return m_containerFormat;
}

void AudioRecorder::setContainerFormat(const QString &newContainerFormat)
{
    m_containerFormat = newContainerFormat;

    const QMetaEnum metaEnum = QMetaEnum::fromType<QMediaFormat::FileFormat>();
    const int value = metaEnum.keyToValue(m_containerFormat.toUtf8().constData());

    QMediaFormat::FileFormat fileFormat;

    if (value != -1) {
        fileFormat = static_cast<QMediaFormat::FileFormat>(value);
    } else {
        fileFormat = QMediaFormat::FileFormat::Ogg;
    }

    m_mediaFormat->setFileFormat(fileFormat);
    setMediaFormat(*m_mediaFormat);
}

QVariantList AudioRecorder::supportedAudioCodecs() const
{
    return m_supportedAudioCodecs;
}

QVariantList AudioRecorder::supportedContainers() const
{
    return m_supportedContainers;
}

void AudioRecorder::slotContainerFormatChanged()
{
    setContainerFormat(SettingsModel::instance()->containerFormat());
}

void AudioRecorder::slotAudioCodecChanged()
{
    setAudioCodec(SettingsModel::instance()->audioCodec());
}

void AudioRecorder::slotAudioQualityChanged()
{
    setAudioQuality(SettingsModel::instance()->audioQuality());
}
