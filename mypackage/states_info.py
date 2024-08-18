from pathlib import Path
import json

THIS_DIR = Path(__file__).parent
CITIES_JSON_FPATH = THIS_DIR / "./cities.json"


def print_json():
    cities_json_contents = CITIES_JSON_FPATH.read_text()
    cities = json.loads(cities_json_contents)
    print(cities)


if __name__ == "__main__":
    print_json()
