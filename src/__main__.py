import dearpygui.dearpygui as dpg
from screeninfo import get_monitors
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from screeninfo import Monitor


class UI:
    def __init__(self, monitor: "Monitor") -> None:
        self.monitor: "Monitor" = monitor
        self.btm_width: int = 50
        self.btm_height: int = 50
        self.offset: int = 0

    def setup(self) -> None:
        btm_x = self.monitor.width - self.btm_width - self.offset
        btm_y = self.offset
        dpg.add_button(
            label="Sair",
            width=self.btm_width,
            height=self.btm_height,
            pos=[btm_x, btm_y]
        )


class App:
    def key_press_handler(self, sender: str, app_data: str) -> None:
        if app_data == dpg.mvKey_Escape:
            dpg.stop_dearpygui()

    def create_window(self) -> None:
        monitor = get_monitors()[0]
        ui = UI(monitor)

        dpg.create_context()

        dpg.create_viewport(
            title='WaterStone',
            width=monitor.width,
            height=monitor.height,
            decorated=False
        )

        with dpg.handler_registry():
            dpg.add_key_press_handler(callback=self.key_press_handler)

        with dpg.window(tag="Win"):
            ui.setup()

        dpg.setup_dearpygui()
        dpg.show_viewport()
        dpg.set_primary_window("Win", True)

        while dpg.is_dearpygui_running():
            dpg.render_dearpygui_frame()

        dpg.destroy_context()


if __name__ == "__main__":
    app = App()
    app.create_window()
