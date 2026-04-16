from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtCore import Qt
from rich import print
import glob
import sys
import os


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)

    def keyPressEvent(self, event):
        if event.key() == Qt.Key.Key_Escape:
            self.close()


def create_window() -> None:
    app = QApplication(sys.argv)

    window = QMainWindow()
    window.show()

    window = MainWindow()

    screen = QGuiApplication.primaryScreen()
    assert screen is not None
    rect = screen.geometry()

    width = rect.width()
    height = rect.height()

    window.setFixedSize(width, height)

    window.show()
    app.exec()


def read_log_data():
    base_path = ""

    try:
        folders = glob.glob(os.path.join(base_path, "Hearthstone_*"))

        if not folders:
            return

        latest_folder = max(folders, key=os.path.getmtime)
        log_file = os.path.join(latest_folder, "Power.log")

        if os.path.exists(log_file):
            with open(log_file, "r") as f:
                lines = f.readlines()
                if lines:
                    last_line = lines[-1].strip()
                    print(f"Log: {last_line}")
        else:
            print("Power.log ainda não criado...")

    except Exception as e:
        print(f"Erro: {str(e)}")


if __name__ == "__main__":
    create_window()
