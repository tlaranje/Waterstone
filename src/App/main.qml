import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    width: Screen.width
    height: Screen.height
    visible: true
    title: "Hello World"
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput

    Shortcut {
        sequences: ["Esc"]
        onActivated: Qt.quit()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Button {
            text: "X"
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            implicitWidth: 70
            implicitHeight: 30
        }

        Text {
            id: text
            text: "Hello World - " + Screen.width + "x" + Screen.height
            color: "white"
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 24
        }

        Item {
            Layout.fillHeight: true
        }
    }
}