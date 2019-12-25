#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedContext>
#include <QAudioRecorder>

#include "recordingmodel.h"
#include "utils.h"
#include "audiorecorder.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("kde.org");
    QCoreApplication::setApplicationName("voicememo");

    qmlRegisterType<AudioRecorder>("VoiceMemo", 1, 0, "AudioRecorder");
    //qmlRegisterUncreatableType<QAudioEncoderSettings>("VoiceMemo", 1, 0, "AudioEncoderSettings", "Created by AudioRecorder");
    qmlRegisterType<RecordingModel>("VoiceMemo", 1, 0, "RecordingModel");
    qmlRegisterSingletonType<Utils>("VoiceMemo", 1, 0, "Utils", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return new Utils;
    });

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
