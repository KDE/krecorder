#include "utils.h"

#include <QDateTime>
#include <QRandomGenerator>

Utils::Utils(QObject *parent) : QObject(parent)
{
}

QString Utils::formatDateTime(const QString &datetime)
{
    const auto qdate = QDateTime::fromString(datetime, Qt::TextDate);
    return qdate.toString(Qt::DefaultLocaleShortDate);
}

QString Utils::formatTime(int time)
{
    const auto qtime = QTime::fromMSecsSinceStartOfDay(time);
    return qtime.toString();
}

int Utils::randomNumber()
{
    auto generator = QRandomGenerator::securelySeeded();
    return generator.bounded(500);
}
