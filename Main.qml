import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: "勤務希望"

    Material.theme: Material.Dark

    property string split_l: firebase.set_split("large")
    property string split_s: firebase.set_split("small")

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
            height: parent.height - menubar.height
            ListView{
                id: outLV
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: shift
                clip: true
                delegate: ScrollView{
                    width: ListView.view.width
                    height: 50
                    ScrollBar.horizontal.position: scroll.position
                    ScrollBar.horizontal.policy:   "AlwaysOff"
                    ListView{
                        anchors.fill: parent
                        orientation: ListView.Horizontal
                        model: display.split(split_l)
                        delegate: Button{
                            width: index === 0 ? 300 : 100
                            text: modelData.split(split_s)[1]
                            visible: text !== ""
                        }
                    }
                }
            }
            ScrollBar{
                id: scroll
                Layout.fillWidth: true
                height: 50
                orientation: "Horizontal"
                policy: "AlwaysOn"
            }
        }
    }
}
