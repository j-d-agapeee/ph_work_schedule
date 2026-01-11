#include "firebase.h"

firebase::firebase() {
    yyyyMM = QDate::currentDate();
    refresh_refToken();
    connect(this, &firebase::signIn_succeeded, this, &firebase::refresh_refToken);
    connect(this, &firebase::refToken_refreshed, this, [=]{ identityToolkit("lookup"); });
    connect(this, &firebase::get_userInfo_finished, this, [=]{
        QNetworkReply *reply = get("user", "permission");
        connect(reply, &QNetworkReply::finished, this, [this, reply]{
            QJsonArray array = QJsonDocument::fromJson(reply->readAll()).object()["fields"].toObject()["admin"].toObject()["arrayValue"].toObject()["values"].toArray();
            for(const auto &value : array){
                QString str = value.toObject()["stringValue"].toString();
                if(str == email){
                    admin = true;
                    emit is_admin(true);
                    return;
                }
            }
            admin = false;
            emit is_admin(false);
        });
    });
    connect(this, &firebase::is_admin, this, &firebase::get_shift);
}

QString firebase::get_localStorage(QString key){
    QString js = QString("localStorage.getItem('%1');").arg(key);
    char* result = emscripten_run_script_string(js.toUtf8().constData());
    return QString(result);
}

void firebase::set_localStorage(QString key, QString value){
    QString js = QString("localStorage.setItem('%1', '%2');").arg(key, value);
    emscripten_run_script(js.toUtf8().constData());
}

QNetworkReply *firebase::send_request(QUrl url, QJsonObject headers, QByteArray method, QByteArray data){
    QNetworkRequest request;
    request.setUrl(url);
    for (const auto &key : headers.keys()) {
        request.setRawHeader(key.toUtf8(), headers[key].toString().toUtf8());
    }
    return manager->sendCustomRequest(request, method, data);
}

void firebase::signUp_signIn(QString endpoint, QString id, QString pass, QString displayName){
    QUrl url("https://identitytoolkit.googleapis.com/v1/accounts:" + endpoint + "?key=" + API_key);

    QJsonObject headers;
    headers["Content-Type"] = "application/json";

    QJsonObject data;
    data["email"]             = id;
    data["password"]          = pass;
    if(endpoint == "signUp")
        data["displayName"]   = displayName;
    data["returnSecureToken"] = true;

    QNetworkReply *reply = send_request(url, headers, "POST", QJsonDocument(data).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply, endpoint]{
        if(reply->error() != QNetworkReply::NoError){
            emit signIn_failed(reply->errorString());
            return;
        }
        QJsonObject jobj = QJsonDocument::fromJson(reply->readAll()).object();
        idToken  = jobj["idToken"].toString();
        refToken = jobj["refreshToken"].toString();
        set_localStorage(prefix + "refToken", refToken);
        if(endpoint == "signUp"){
            identityToolkit("sendOobCode");
            return;
        }
        emit signIn_succeeded();
    });
}

void firebase::refresh_refToken(){
    QUrl url("https://securetoken.googleapis.com/v1/token?key=" + API_key);
    QJsonObject headers, data;
    headers["Content-Type"] = "application/json";
    data["grant_type"] = "refresh_token";
    data["refresh_token"] = get_localStorage(prefix + "refToken");

    QNetworkReply *reply = send_request(url, headers, "POST", QJsonDocument(data).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]{
        if(reply->error() != QNetworkReply::NoError){
            emit refToken_notFound();
            return;
        }
        QJsonObject jobj = QJsonDocument::fromJson(reply->readAll()).object();
        idToken  = jobj["id_token"].toString();
        refToken = jobj["refresh_token"].toString();
        set_localStorage(prefix + "refToken", refToken);
        emit refToken_refreshed();
    });
}

void firebase::identityToolkit(QString endpoint){
    //"sendOobCode"     send verify mail or reset password
    //"lookup"          get user info = [email, is verified, displayName]
    //"update"          update user displayName
    QUrl url("https://identitytoolkit.googleapis.com/v1/accounts:" + endpoint + "?key=" + API_key);

    QJsonObject headers, data;
    headers["Content-Type"] = "application/json";
    if(endpoint == "sendOobCode")
        data["requestType"] = "VERIFY_EMAIL";
    data["idToken"]         = idToken;

    QNetworkReply *reply = send_request(url, headers, "POST", QJsonDocument(data).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply, endpoint]{
        QJsonObject jobj = QJsonDocument::fromJson(reply->readAll()).object();
        if(endpoint == "sendOobCode"){
            emit send_verified_mail_succeeded();
        }
        if(endpoint == "lookup"){
            jobj = jobj["users"].toArray().at(0).toObject();
            is_email_verified = jobj["emailVerified"].toBool();
            email             = jobj["email"].toString();
            username          = jobj["displayName"].toString();
            emit get_userInfo_finished();
        }
        if(endpoint == "update"){

        }
    });
}

QNetworkReply *firebase::get(QString collectionId, QString documentId){
    QUrl url("https://firestore.googleapis.com/v1/projects/phdatabase-b0ee2/databases/(default)/"
             "documents/" + collectionId + "/" + documentId);

    QJsonObject headers;
    headers["Authorization"] = "Bearer " + idToken;

    return send_request(url, headers, "GET", "");
}

QNetworkReply *firebase::patch(QString collectionId, QString documentId, QString key, QJsonObject fields){
    //if argument fields == QJsonObject(), the key is removed from firestore.
    QUrl url("https://firestore.googleapis.com/v1/projects/phdatabase-b0ee2/databases/(default)/"
             "documents/" + collectionId + "/" + documentId + "?updateMask.fieldPaths=%60" + key + "%60");

    QJsonObject headers;
    headers["Authorization"] = "Bearer " + idToken;

    QJsonObject value;
    value["fields"] = fields;

    return send_request(url, headers, "PATCH", QJsonDocument(value).toJson());
}

void firebase::get_shift(bool admin){
    QNetworkReply *reply;
    if(admin) reply = get("shift", "");
    else      reply = get("shift", username);

    connect(reply, &QNetworkReply::finished, this, [this, reply, admin]{
        QJsonObject jobj = QJsonDocument::fromJson(reply->readAll()).object();
        QJsonArray array;
        if(admin){
            array = jobj["documents"].toArray();
            // if(type == "requested"){
            // }
        }
        else{
            array << jobj;
        }
        QStringList out;
        for (const auto &value : array) {
            QJsonObject fields = value.toObject()["fields"].toObject();
            QString str;
            for (const auto &key : fields.keys()) {
                QDate keyDate = QDate::fromString(key, "yyyyMMdd");
                if(keyDate.year() == yyyyMM.year() && keyDate.month() == yyyyMM.month()){
                    str.append()
                }
            }
        }
    });

}
