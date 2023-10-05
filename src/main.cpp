/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QApplication>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QCommandLineParser>
#include <QQuickStyle>
#include <QtQml>

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "about.h"
#include "audioplayer.h"
#include "audioprober.h"
#include "audiorecorder.h"
#include "recording.h"
#include "recordingmodel.h"
#include "settingsmodel.h"
#include "utils.h"
#include "version.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    // set default style
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }
    // if using org.kde.desktop, ensure we use kde style if possible
    if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORMTHEME")) {
        qputenv("QT_QPA_PLATFORMTHEME", "kde");
    }

    QApplication app(argc, argv);
    
    KLocalizedString::setApplicationDomain("krecorder");
    
    KAboutData aboutData(QStringLiteral("krecorder"),
                         QStringLiteral("Recorder"),
                         QStringLiteral(KRECORDER_VERSION_STRING),
                         QStringLiteral("Audio recorder"),
                         KAboutLicense::GPL,
                         i18n("© 2020-2022 KDE Community"));
    aboutData.addAuthor(i18n("Devin Lin"), QString(), QStringLiteral("devin@kde.org"));
    aboutData.addAuthor(i18n("Jonah Brüchert"), QString(), QStringLiteral("jbb@kaidan.im"));
    KAboutData::setApplicationData(aboutData);
    
    QCommandLineParser parser;
    parser.addVersionOption();
    parser.process(app);

    qmlRegisterType<Recording>("KRecorder", 1, 0, "Recording");
    qmlRegisterType<AudioProber>("KRecorder", 1, 0, "AudioProber");
    qmlRegisterSingletonType<Utils>("KRecorder", 1, 0, "Utils", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return new Utils;
    });

    // pre-initialize settings model to apply settings to the AudioRecorder instance
    SettingsModel::instance();

    qmlRegisterSingletonType<AudioPlayer>("KRecorder", 1, 0, "AudioPlayer", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return AudioPlayer::instance();
    });

    qmlRegisterSingletonType<AudioRecorder>("KRecorder", 1, 0, "AudioRecorder", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return AudioRecorder::instance();
    });

    qmlRegisterSingletonType<RecordingModel>("KRecorder", 1, 0, "RecordingModel", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return RecordingModel::instance();
    });

    qmlRegisterSingletonType<SettingsModel>("KRecorder", 1, 0, "SettingsModel", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return SettingsModel::instance();
    });

    qmlRegisterSingletonInstance("KRecorder", 1, 0, "AboutType", &AboutType::instance());
    
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // required for X11
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.krecorder")));

    return app.exec();
}
