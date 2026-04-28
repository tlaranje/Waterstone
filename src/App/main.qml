import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: Screen.width
    height: Screen.height
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    Item {
        anchors.fill: parent

        Button {
            id: menuButton
            anchors.top: parent.top
            anchors.right: parent.right

            implicitWidth: 50
            implicitHeight: 50

            contentItem: Image {
                source: "../../img/drawing.svg"

                sourceSize.width: 64
                sourceSize.height: 64

                width: 24
                height: 24

                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter

                antialiasing: true
                smooth: true

                opacity: menuButton.pressed ? 0.5 : 1.0
            }


            function updateMask() {
                var pos = menuButton.mapToItem(null, 0, 0)

                var finalW = menuButton.width
                var finalH = menuButton.height
                var finalX = pos.x

                if (contextMenu.visible) {
                    finalW = contextMenu.width
                    finalH = menuButton.height + contextMenu.height
                    finalX = pos.x + contextMenu.x
                }

                backend.change_mask(finalX, pos.y, finalW, finalH)
            }

            onPressed: {
                if (contextMenu.visible) {
                    contextMenu.dismiss()
                } else {
                    contextMenu.open()
                }
                updateMask()
            }

            background: Rectangle {
                color: menuButton.pressed ? "#444" : "#222"
                border.color: "cyan"
                radius: 5
            }

            Menu {
                id: contextMenu
                x: -(implicitWidth - menuButton.width)
                y: menuButton.height

                implicitWidth: menuButton.width

                closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape
                onClosed: menuButton.updateMask()

                background: Rectangle {
                    color: "#222"
                    border.color: "cyan"
                    radius: 10
                }

                MenuItem {
                    text: "Ação 1"
                    contentItem: Text { text: "Ação 1"; color: "white" }
                    onTriggered: console.log("Ação 1")
                }

                MenuItem {
                    text: "Sair"
                    contentItem: Text { text: "Sair"; color: "red" }
                    onTriggered: Qt.quit()
                }
            }
        }

        Rectangle {
            id: debugMaskVisual
            color: "#88FF00FF"
            border.color: "red"
            border.width: 2
            z: 999

            visible: contextMenu.visible

            x: contextMenu.visible ? (menuButton.mapToItem(null, 0, 0).x + contextMenu.x) : menuButton.mapToItem(null, 0, 0).x
            y: menuButton.mapToItem(null, 0, 0).y
            width: contextMenu.visible ? contextMenu.width : menuButton.width
            height: contextMenu.visible ? (menuButton.height + contextMenu.height) : menuButton.height

            Text {
                anchors.centerIn: parent
                text: "MASK AREA"
                color: "white"
                font.pixelSize: 10
            }
        }
    }
}