/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedContext>
#include <QAudioRecorder>
#include <QCommandLineParser>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include "recordingmodel.h"
#include "utils.h"
#include "audioplayer.h"
#include "audiorecorder.h"
#include "audioprober.h"
#include "settingsmodel.h"
#include "version.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCommandLineParser parser;
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    parser.addVersionOption();

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("kde.org");
    QCoreApplication::setApplicationName("KRecorder");
    QCoreApplication::setApplicationVersion(QStringLiteral(KRECORDER_VERSION_STRING));
    parser.process(app);

    qmlRegisterType<Recording>("KRecorder", 1, 0, "Recording");
    qmlRegisterType<AudioProber>("KRecorder", 1, 0, "AudioProber");
    //qmlRegisterUncreatableType<QAudioEncoderSettings>("VoiceMemo", 1, 0, "AudioEncoderSettings", "Created by AudioRecorder");
    qmlRegisterSingletonType<Utils>("KRecorder", 1, 0, "Utils", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return new Utils;
    });
    qmlRegisterSingletonType<SettingsModel>("KRecorder", 1, 0, "AudioPlayer", [] (QQmlEngine *, QJSEngine *) -> QObject* {
       return AudioPlayer::instance();
    });
    qmlRegisterSingletonType<SettingsModel>("KRecorder", 1, 0, "AudioRecorder", [] (QQmlEngine *, QJSEngine *) -> QObject* {
       return AudioRecorder::instance();
    });
    qmlRegisterSingletonType<RecordingModel>("KRecorder", 1, 0, "RecordingModel", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return RecordingModel::instance();
    });
    qmlRegisterSingletonType<SettingsModel>("KRecorder", 1, 0, "SettingsModel", [] (QQmlEngine *, QJSEngine *) -> QObject* {
       return SettingsModel::instance();
    });
    
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
