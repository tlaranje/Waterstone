import sys
import requests
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QLabel, QVBoxLayout, QWidget
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QPixmap, QGuiApplication


class HearthstoneOverlay(QMainWindow):
    def __init__(self):
        super().__init__()
        self.cards_data = []
        self.card_dict = {}
        self.card_display = None

        self.setup_overlay_properties()
        self.load_current_season_data()

        # Create dict for fast lookup: name -> id
        self.card_dict = {
            card['name']: card['id'] for card in self.cards_data
        }
        print(self.card_dict)
        self.setup_ui()

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
        self.setFixedSize(screen.width(), screen.height())

    def setup_ui(self):
        """Initializes the user interface."""
        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)
        self.layout = QVBoxLayout(self.central_widget)

        self.card_display = QLabel()
        self.layout.addWidget(self.card_display)

        # Example: Show a card that is iconic in the current pool
        # If the card isn't found, it won't crash
        example_card = "Titus Rivendare"
        card_id = self.card_dict.get(example_card)

        if card_id:
            self.display_card_art(card_id)

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
