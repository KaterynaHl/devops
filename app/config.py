import json

CONFIG_PATH = "/etc/mywebapp/config.json"


def load_config():
    with open(CONFIG_PATH) as config_file:
        return json.load(config_file)