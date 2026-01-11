#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <firebase.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    firebase fb;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("firebase", &fb);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ph_work_schedule", "Main");

    return app.exec();
}
