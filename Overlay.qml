import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    anchors.fill: parent

    property string registName  : ""
    property int    day         : 0
    property string requested   : ""
    property string confirmed   : ""
    property int    currentYear : 0
    property int    currentMonth: 0

    signal jump_yyyyMM_accepted()

    Connections{
        target: firebase

        function onRefToken_notFound(){ signIn.open() }
        function onSignIn_failed(err){ signErr.text = err }
        function onSend_verified_mail_succeeded(){ signErr.text = "本人確認のメール送信成功" }
        function onIs_admin(admin){ signUp.visible = admin }
        function onRegist_clicked(reg, d, req, con){
            registName = reg
            day        = d
            requested  = req
            confirmed  = con
            regist.open()
        }
        function onJump_yyyyMM(yyyyMM){
            console.log(yyyyMM.slice(0,4))
            currentYear  = Number(yyyyMM.slice(0, 4))
            currentMonth = Number(yyyyMM.slice(5, 2))
            jump_yyyyMM.open()
        }
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
    Dialog{
        id: regist
        anchors.centerIn: parent
        ColumnLayout{
            Label{
                text: registName + " " + day + "日 " + "登録"
            }
            TextField{
                id: registRequested
                text: requested
            }
            TextField{
                id: registConfirmed
                text: confirmed
            }
        }
    }
    Dialog{
        id: jump_yyyyMM
        anchors.centerIn: parent
        ColumnLayout{
            Label{
                text: "指定した年月に移動"
            }
            SpinBox{
                id: jumpY
                from : currentYear - 5
                to   : currentYear + 5
                value: currentYear
            }
            SpinBox{
                id: jumpM
                from : 1
                to   : 12
                value: currentMonth
            }
        }
        standardButtons: Dialog.Ok|Dialog.Cancel
        onAccepted: {
            firebase.add_yyyyMM(jumpY.value - currentYear, jumpM.value - currentMonth)
            firebase.get_shift()
        }
    }
}
