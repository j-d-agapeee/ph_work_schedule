import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: "勤務希望"

    Material.theme: Material.Dark

    FontLoader{
        id: jpFont
        source: "https://j-d-agapeee.github.io/ph_work_schedule/HiraMaruProN-W4-AlphaNum-01.otf"
        // onStatusChanged: parent.font.family = "Hiragino Maru Gothic Pro"// font.family
    }
    // font: jpFont
    font.family: "Hiragino Maru Gothic Pro"

    OverLay{}

    Column{
        anchors.fill: parent

        MenuBar{
            id: menubar
            width: parent.width
            Material.background: "#222222"
            Menu{
                title: "メニュー"
                MenuItem{
                    text: "ログイン/新規登録"
                    onTriggered: firebase.refToken_notFound()
                }
            }
        }

        ColumnLayout{
            width: parent.width
            TabBar{
                Layout.fillWidth: true
                TabButton{
                    text: "にほんご"

                }
                TabButton{
                    text: "漢字"
                }
            }
        }
    }
}
