import sys
import requests
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QLabel, QVBoxLayout, QWidget, QPushButton,
    QHBoxLayout
)
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QPixmap, QGuiApplication


class HearthstoneOverlay(QMainWindow):
    def __init__(self) -> None:
        super().__init__()
        self.screen_size: tuple[float, float] = (0, 0)
        self.cards_data: list = []
        self.card_dict = {}
        self.card_display = None

        self.setup_overlay_properties()
        self.load_current_season_data()

        # Create dict for fast lookup: name -> id
        self.card_dict = {
            card['name']: card['id'] for card in self.cards_data
        }
        self.setup_ui()

    def on_click(self):
        print('PyQt5 button click')

    def load_current_season_data(self):
        """Downloads and filters cards active in the current BG season."""
        print("Loading current Battlegrounds pool...")
        url = "https://api.hearthstonejson.com/v1/latest/enUS/cards.json"
        try:
            response = requests.get(url, timeout=10)
            all_cards = response.json()

            # Filter for cards actually in the Battlegrounds game pool
            self.cards_data = [
                card for card in all_cards
                if card.get("battlegroundsPool") is True
                or card.get("set") == "BATTLEGROUNDS"
            ]

            # Sort by Tech Level (Tier) to keep it organized
            self.cards_data.sort(key=lambda x: x.get("techLevel", 0))

            print(f"Loaded {len(self.cards_data)} active BG cards!")
        except Exception as e:
            print(f"Error loading data: {e}")

    def setup_overlay_properties(self):
        """Configures window transparency and flags."""
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setWindowFlags(
            Qt.WindowType.FramelessWindowHint |
            Qt.WindowType.WindowStaysOnTopHint
        )
        screen = QGuiApplication.primaryScreen().geometry()
        self.screen_size = (screen.width(), screen.height())
        self.setFixedSize(screen.width(), screen.height())

    def setup_ui(self):
        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)
        # Layout Principal Horizontal (Barra Lateral | Área de Conteúdo)
        self.main_layout = QHBoxLayout(self.central_widget)

        # Painel de Botões
        self.button_panel = QVBoxLayout()
        self.central_widget.setMaximumWidth(self.screen_size[0])

        btms = []
        btms.append(QPushButton("Atualizar Pool"))
        btms.append(QPushButton("Ver Stats"))

        # Estilização básica para não ficar feio
        for b in btms:
            b.setStyleSheet("""
                QPushButton {
                    background-color: #3d2b1f;
                    color: #f0d4a0;
                    border: 2px solid #8e6d3d;
                    border-radius: 4px;
                    font-family: 'Arial';
                    font-size: 14px;
                }
                QPushButton:hover {
                    background-color: #5a4030;
                    border-color: #d4af37;
                }
            """)
            self.button_panel.addWidget(b, alignment=Qt.AlignRight)
        self.button_panel.addStretch()

        # Adiciona o painel e o display de cards ao layout principal
        self.main_layout.addLayout(self.button_panel)

        self.card_display = QLabel()
        self.main_layout.addWidget(self.card_display)

    def display_card_art(self, card_id):
        """Fetches card art from HearthstoneJSON Art API."""
        img_url = (
            "https://art.hearthstonejson.com/v1/"
            f"render/latest/enUS/256x/{card_id}.png"
        )
        try:
            image_data = requests.get(img_url, timeout=10).content
            pixmap = QPixmap()
            pixmap.loadFromData(image_data)
            if self.card_display:
                self.card_display.setPixmap(pixmap)
        except Exception as e:
            print(f"Error loading image: {e}")

    def keyPressEvent(self, event):
        """Closes the window on Escape key press."""
        if event.key() == Qt.Key.Key_Escape:
            self.close()


def main():
    """Main entry point of the application."""
    app = QApplication(sys.argv)
    window = HearthstoneOverlay()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
