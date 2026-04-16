import os
import glob


def update_log_data():
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
    update_log_data()
