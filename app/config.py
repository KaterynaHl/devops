import json
import os


DEFAULT_CONFIG_PATHS = [
    os.environ.get("APP_CONFIG_PATH"),
    "/etc/mywebapp/config.json",
    "config/app_config.json",
    "config.json.example",
]


def load_config():
    for config_path in DEFAULT_CONFIG_PATHS:
        if config_path and os.path.exists(config_path):
            with open(config_path, encoding="utf-8") as config_file:
                return json.load(config_file)

    raise FileNotFoundError("Application config file was not found")