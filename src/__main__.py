import sys
from PySide6.QtGui import QGuiApplication, QRegion
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QRect, Slot, QObject
from pynput import keyboard
from typing import Any


def on_press(key: str) -> None:
    if key == keyboard.Key.esc:
        QGuiApplication.quit()


class Bridge(QObject):
    def __init__(self, window: Any) -> None:
        super().__init__()
        self._window = window

    @Slot(int, int, int, int)
    def change_mask(self, x: int, y: int, w: int, h: int) -> None:
        area = QRect(x, y, w, h)
        self._window.setMask(QRegion(area))


if __name__ == "__main__":
    listener = keyboard.Listener(on_press=on_press)
    listener.start()

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    engine.addImportPath(sys.path[0] + "/src")
    engine.loadFromModule("App", "Main")

    if not engine.rootObjects():
        sys.exit(-1)

    window = engine.rootObjects()[0]
    bridge = Bridge(window)
    engine.rootContext().setContextProperty("backend", bridge)

    initial_x = app.primaryScreen().size().width() - 70
    bridge.change_mask(initial_x, 0, 100, 100)

    exit_code = app.exec()
    sys.exit(exit_code)
