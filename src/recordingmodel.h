#ifndef RECORDINGMODEL_H
#define RECORDINGMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSettings>

#include <QJsonObject>

class RecordingModel : public QAbstractListModel
{
    Q_OBJECT

    enum Roles {
        RecordingTimeRole = Qt::UserRole,
        DurationRole,
        FileNameRole
    };

public:
    explicit RecordingModel(QObject *parent = nullptr);
    ~RecordingModel();

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Q_INVOKABLE void insertRecording(const QJsonObject& recording);
    Q_INVOKABLE void deleteRecording(const int index);

signals:

private:
    QSettings* m_settings;
    QVariantList m_recordings;
};

#endif // RECORDINGMODEL_H
