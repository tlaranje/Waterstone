import sys
import json
from PySide6.QtGui import QGuiApplication, QRegion
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QRect, Slot, QObject, Qt
from pynput import keyboard
from typing import Any


def on_press(key: str) -> None:
    if key == keyboard.Key.esc:
        QGuiApplication.quit()


class Bridge(QObject):
    def __init__(self, window: Any) -> None:
        super().__init__()
        self._window = window

    @Slot(str)
    def update_mask(self, rects_json: str) -> None:
        """Recebe um array JSON de {x, y, w, h} e aplica a união como máscara."""
        if self._window is None:
            return
        try:
            rects = json.loads(rects_json)
            region = QRegion()
            for r in rects:
                region = region.united(
                    QRegion(QRect(int(r["x"]), int(r["y"]),
                                  int(r["w"]), int(r["h"])))
                )
            self._window.setMask(region)
        except Exception as e:
            print(f"[update_mask] Erro ao aplicar máscara: {e}", file=sys.stderr)


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    bridge = Bridge(None)
    engine.rootContext().setContextProperty("backend", bridge)

    engine.addImportPath(sys.path[0] + "/src")
    engine.loadFromModule("App", "Main")

    if not engine.rootObjects():
        sys.exit(-1)

    window = engine.rootObjects()[0]
    bridge._window = window

    window.setFlags(
        Qt.FramelessWindowHint |
        Qt.WindowStaysOnTopHint
    )

    screen_w = app.primaryScreen().size().width()
    btn_x = screen_w - 40
    initial_region = QRegion(QRect(btn_x, 0, 40, 40))
    window.setMask(initial_region)

    sys.exit(app.exec())