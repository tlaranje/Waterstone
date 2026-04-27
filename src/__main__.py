import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from pynput import keyboard


def on_press(key: str) -> None:
    if key == keyboard.Key.esc:
        print("Esc pressionado globalmente! Saindo...")
        QGuiApplication.quit()


if __name__ == "__main__":
    listener = keyboard.Listener(on_press=on_press)
    listener.start()
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.addImportPath(sys.path[0] + "/src")
    engine.loadFromModule("App", "Main")
    if not engine.rootObjects():
        sys.exit(-1)
    exit_code = app.exec()
    del engine
    sys.exit(exit_code)
