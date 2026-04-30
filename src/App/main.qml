import QtQuick
import QtQuick.Controls

Window {
    id: root
    width: Screen.width
    height: Screen.height
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    function updateMask() {
        if (typeof backend === "undefined" || !backend) return
        var rects = customMenuButton.computeMaskRects()
        backend.update_mask(JSON.stringify(rects))
    }

    Timer {
        id: initTimer
        interval: 100
        repeat: false
        running: true
        onTriggered: root.updateMask()
    }

    Item {
        anchors.fill: parent

        CardsMenu {
            id: customMenuButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 0

            onMaskRectsChanged: root.updateMask()
        }
    }
}
