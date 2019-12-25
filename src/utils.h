#ifndef UTILS_H
#define UTILS_H

#include <QObject>

class Utils : public QObject
{
    Q_OBJECT

public:
    explicit Utils(QObject *parent = nullptr);

    Q_INVOKABLE static QString formatDateTime(const QString &time);
    Q_INVOKABLE static QString formatTime(int time);

    Q_INVOKABLE static int randomNumber();
};

#endif // UTILS_H
