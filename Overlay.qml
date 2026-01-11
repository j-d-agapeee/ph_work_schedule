import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    anchors.fill: parent
    Connections{
        target: firebase

        function onRefToken_notFound(){ signIn.open() }
        function onSignIn_failed(err){ signErr.text = err }
        function onSend_verified_mail_succeeded(){ signErr.text = "本人確認のメール送信成功" }
        function onIs_admin(admin){ signUp.visible = admin }
    }

    Dialog{
        id: signIn
        anchors.centerIn: parent
        width: parent.width > 400 ? parent.width * 0.7 : 400
        ColumnLayout{
            width: parent.width
            spacing: 10
            TabBar{
                id: signEndpoint
                Layout.fillWidth: true
                // Material.background:
                TabButton{
                    text: "ログイン"
                }
                TabButton{
                    id: signUp
                    text: "新規登録"
                }
            }
            TextField{
                Layout.fillWidth: true
                id: signId
                placeholderText: "ID(メールアドレス)"
            }
            TextField{
                Layout.fillWidth: true
                id: signPass
                placeholderText: "パスワード"
                echoMode: "Password"
            }
            TextField{
                visible: signEndpoint.currentIndex === 1
                Layout.fillWidth: true
                id: signDisplayName
                placeholderText: "表示名"
            }
            Label{
                Layout.fillWidth: true
                id: signErr
            }
            DialogButtonBox{
                id: signDbb
                Layout.alignment: Qt.AlignRight
                standardButtons: Dialog.Ok
                enabled: {
                    if(signEndpoint.currentIndex === 0)
                        return signId.text !== ""
                    else
                        return signId.text !== "" && signDisplayName.text !== ""
                }
                onClicked: {
                    signErr.text = ""
                    firebase.signUp_signIn(
                            signEndpoint.currentIndex === 0 ? "signInWithPassword" : "signUp",
                                signId.text, signPass.text, signDisplayName.text)
                }
            }
        }
    }
}
