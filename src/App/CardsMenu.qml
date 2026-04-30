import QtQuick
import QtQuick.Controls

Button {
    id: menuButton
    property alias isMenuOpen: contextMenu.visible
    property bool _isClosing: false

    // Emitido sempre que a área interactiva muda (popup abre/fecha, submenu abre/fecha)
    signal maskRectsChanged()

    // Margem extra para o border+radius dos rectângulos não serem cortados pela máscara
    readonly property int _maskPad: 3

    // Devolve array de {x, y, w, h} em coordenadas de janela cobrindo
    // todos os elementos actualmente visíveis e clicáveis.
    function computeMaskRects() {
        var p = menuButton._maskPad
        var rects = []

        // 1. Botão — sempre presente
        var btnPos = menuButton.mapToItem(null, 0, 0)
        rects.push({
            x: Math.round(btnPos.x) - p,
            y: Math.round(btnPos.y) - p,
            w: menuButton.implicitWidth  + p * 2,
            h: menuButton.implicitHeight + p * 2
        })

        // 2. Popup principal (contextMenu)
        if (contextMenu.visible) {
            var popupW = Math.round(contentRow.implicitWidth + contextMenu.padding * 2)
            var popupH = Math.round(contentRow.implicitHeight + contextMenu.padding * 2)
            var popupX = Math.round(btnPos.x + contextMenu.x)
            var popupY = Math.round(btnPos.y + contextMenu.y)
            rects.push({
                x: popupX - p,
                y: popupY - p,
                w: popupW  + p * 2,
                h: popupH  + p * 2
            })

            // 3. Submenu aberto (se existir)
            for (var i = 0; i < contentRowRepeater.count; i++) {
                var delegate = contentRowRepeater.itemAt(i)
                if (delegate && delegate.subMenuInstance && delegate.subMenuInstance.visible) {
                    var sm = delegate.subMenuInstance
                    var smPos = delegate.mapToItem(null, sm.x, sm.y)
                    rects.push({
                        x: Math.round(smPos.x) - p,
                        y: Math.round(smPos.y) - p,
                        w: Math.round(sm.implicitWidth)  + p * 2,
                        h: Math.round(sm.implicitHeight) + p * 2
                    })
                }
            }
        }

        return rects
    }

    Timer {
        id: closingTimer
        interval: 150
        onTriggered: menuButton._isClosing = false
    }

    // Adia o recálculo da máscara para o próximo ciclo do event loop,
    // garantindo que o Qt já terminou o layout antes de lermos as dimensões.
    Timer {
        id: maskUpdateTimer
        interval: 0
        repeat: false
        onTriggered: menuButton.maskRectsChanged()
    }

    function scheduleMaskUpdate() {
        maskUpdateTimer.restart()
    }

    implicitWidth: 40
    implicitHeight: 40

    onClicked: {
        if (contextMenu.visible) contextMenu.close()
        else if (!_isClosing) contextMenu.open()
    }

    contentItem: Image {
        source: "../../img/Card_Menu.svg"
        sourceSize: Qt.size(64, 64)
        fillMode: Image.PreserveAspectFit
        opacity: menuButton.down ? 0.5 : 1.0
    }

    background: Rectangle {
        color: menuButton.down ? "#444" : "#222"
        border.color: "cyan"
        radius: 5
    }

    Popup {
        id: contextMenu
        padding: 5
        x: -(contentRow.implicitWidth + (padding * 2) - menuButton.width) - 2
        y: menuButton.height + 2
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // Notifica a janela pai quando o popup abre ou fecha
        onVisibleChanged: menuButton.scheduleMaskUpdate()

        onAboutToHide: {
            menuButton._isClosing = true
            closingTimer.start()
        }

        contentItem: Row {
            id: contentRow
            spacing: 4

            Repeater {
                id: contentRowRepeater
                model: [
                    { "label": "1", "color": "white",
                      "subMenu": ["Opção 1.1", "Opção 1.2"] },
                    { "label": "2", "color": "white",
                      "subMenu": ["Opção 2.1", "Opção 2.2"] },
                    { "label": "3", "color": "white",
                      "subMenu": ["Opção 3.1", "Opção 3.2"] },
                    { "label": "4", "color": "white",
                      "subMenu": ["Opção 4.1", "Opção 4.2"] },
                    { "label": "5", "color": "white",
                      "subMenu": ["Opção 5.1", "Opção 5.2"] },
                    { "label": "X", "color": "red",
                      "subMenu": null, "action": function() { Qt.quit() } }
                ]

                delegate: AbstractButton {
                    id: itemDelegate
                    property alias subMenuInstance: subMenu
                    implicitWidth: 40
                    implicitHeight: 40
                    hoverEnabled: true

                    contentItem: Text {
                        text: modelData.label
                        font.pixelSize: 16
                        color: (itemDelegate.hovered || subMenu.visible) ?
                                "cyan" : modelData.color
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: (itemDelegate.hovered || subMenu.visible) ?
                               "#333" : "transparent"
                        radius: 4
                        border.color: (itemDelegate.hovered || subMenu.visible) ?
                                      "cyan" : "transparent"
                        border.width: 1
                    }

                    onClicked: {
                        if (modelData.subMenu) {
                            if (subMenu.visible) subMenu.close()
                            else subMenu.open()
                        } else if (modelData.action) {
                            modelData.action()
                            contextMenu.close()
                        }
                    }

                    Menu {
                        id: subMenu
                        y: parent.height + 6

                        // Bordo direito do submenu a 2 px do bordo do ecrã
                        x: {
                            var itemGlobalX = itemDelegate.mapToItem(null, 0, 0).x
                            return Screen.width - itemGlobalX - implicitWidth - 2
                        }

                        implicitWidth: 200

                        // Notifica quando o submenu abre ou fecha
                        onVisibleChanged: menuButton.scheduleMaskUpdate()
                        onImplicitWidthChanged: if (visible) menuButton.scheduleMaskUpdate()
                        onImplicitHeightChanged: if (visible) menuButton.scheduleMaskUpdate()

                        Repeater {
                            model: modelData.subMenu
                            MenuItem {
                                text: modelData
                                onTriggered: contextMenu.close()
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.highlighted ? "cyan" : "white"
                                }
                                background: Rectangle {
                                    color: parent.highlighted ? "#444" : "#222"
                                }
                            }
                        }

                        background: Rectangle {
                            color: "#222"
                            border.color: "cyan"
                            border.width: 1
                            radius: 5
                        }
                    }
                }
            }
        }

        background: Rectangle {
            color: "#222"
            border.color: "cyan"
            border.width: 1
            radius: 5
        }
    }
}
