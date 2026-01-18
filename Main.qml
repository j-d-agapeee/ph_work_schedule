import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: "勤務希望"

    Material.theme: Material.Dark

    property string split_l : firebase.set_split("large")
    property string split_s : firebase.set_split("small")
    property var    names   : []
    property var    days    : []
    property int    rowWidth: 0
    property string yyyyMM  : firebase.set_yyyyMM()

    FontLoader{
        id: jpFont
        source: "https://j-d-agapeee.github.io/ph_work_schedule/HiraMaruProN-W4-AlphaNum-01.otf"
        // onStatusChanged: parent.font.family = "Hiragino Maru Gothic Pro"// font.family
    }
    // font: jpFont
    font.family: "Hiragino Maru Gothic Pro"

    OverLay{
        onJump_yyyyMM_accepted: yyyyMM = firebase.set_yyyyMM()
    }

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

            Row{
                Layout.fillWidth: true
                Repeater{
                    model:["前月", yyyyMM, "次月"]

                    delegate: Button{
                        text: modelData
                        onClicked: {
                            if(index === 0) firebase.add_yyyyMM(0, -1)
                            if(index === 2) firebase.add_yyyyMM(0, 1)
                            if(index === 1) {
                                firebase.jump_yyyyMM(yyyyMM)
                                return
                            }
                            firebase.get_shift()
                            yyyyMM = firebase.set_yyyyMM()
                        }
                    }
                }
            }

            ScrollView{
                Layout.fillWidth: true
                Layout.fillHeight: true
                ScrollBar.horizontal.policy: "AlwaysOn"
                ScrollBar.horizontal.height: 20
                contentWidth: rowWidth
                ListView{
                    anchors.fill: parent
                    model: shift
                    clip: true
                    spacing: 2
                    delegate: ListView{
                        width: rowWidth
                        height: 60
                        Component.onCompleted: rowWidth = contentWidth
                        property int row: index
                        orientation: ListView.Horizontal
                        model: display.split(split_l)
                        spacing: 2
                        delegate: Rectangle{
                            width: index === 0 ? 300 : 100
                            height: ListView.view.height
                            radius: height/2
                            color: {
                                if(shiftText.text.includes("土")) return "#2196F3"
                                if(shiftText.text.includes("日")) return "#FF7E91"
                                else                              return "#444444"
                            }
                            Label{
                                id: shiftText
                                anchors.fill: parent
                                horizontalAlignment: "AlignHCenter"
                                verticalAlignment:   "AlignVCenter"
                                Material.foreground: text.includes("土") || text.includes("日") ? "black" : undefined
                                text: {
                                    if(index === 0){
                                        names.push(modelData.split(split_s)[0])
                                        return modelData.split(split_s)[0]
                                    }
                                    if(row)
                                        return modelData.split(split_s)[1] + "\n" + modelData.split(split_s)[2]
                                    else
                                        return modelData.split(split_s)[0]  //row === 0
                                }
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: firebase.regist_clicked(names[row], index, modelData.split(split_s)[1], modelData.split(split_s)[2])
                            }
                        }
                    }
                }
            }
        }
    }
}
