#ifndef FIREBASE_H
#define FIREBASE_H

#include <QObject>
#include <QtNetwork>

#include <emscripten.h>

class firebase : public QObject
{
    Q_OBJECT
public:
    firebase();

    //variable
    QNetworkAccessManager *manager = new QNetworkAccessManager;
    QString API_key = "AIzaSyAhav7lsi8p2QNmhIfAO1MoLy5vcOZ1SM0"; //leak ok
    QString prefix  = "phws_";
    QString split_l = "({[";
    QString split_s = ")}]";
    QString idToken, refToken;

    //user info
    QString email, username;
    bool    is_email_verified;
    bool    admin = false;

    //date info
    QDate yyyyMM = QDate(QDate::currentDate().year(), QDate::currentDate().month(), 1);

    //QML
    QStringListModel shift;

    //function
    QString get_localStorage(QString key);
    void    set_localStorage(QString key, QString value);
    QNetworkReply *send_request(QUrl url, QJsonObject headers, QByteArray method, QByteArray data);
    void    refresh_refToken();
    void    identityToolkit(QString endpoint);

signals:
    void refToken_notFound();
    void signIn_failed(QString err);
    void signIn_succeeded();
    void refToken_refreshed();
    void send_verified_mail_succeeded();
    void get_userInfo_finished();
    void is_admin(bool admin);
    void regist_clicked(QString name, int day, QString requested, QString confirmed);
    void jump_yyyyMM(QString yM);

public slots:
    QString set_split(QString ls){ return ls == "large" ? split_l : split_s; }
    QString set_yyyyMM(){ return yyyyMM.toString("yyyy/MM"); }
    void signUp_signIn(QString endpoint, QString id, QString pass, QString displayName);
    QNetworkReply *get(QString collectionId, QString documentId);
    QNetworkReply *patch(QString collectionId, QString documentId, QString key, QJsonObject fields);
    void get_shift();
    void add_yyyyMM(int addY, int addM);
};

#endif // FIREBASE_H
