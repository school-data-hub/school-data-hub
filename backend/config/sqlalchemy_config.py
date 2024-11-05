import os

from dotenv import load_dotenv

load_dotenv()
basedir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

sqlalchemy_config = {
    "SECRET_KEY": "matse123",
    "SQLALCHEMY_DATABASE_URI": "sqlite:///" + os.path.join(basedir, "db.sqlite3"),
    "SQLALCHEMY_TRACK_MODIFICATIONS": False,
    "MAX_CONTENT_LENGTH": 32 * 1024 * 1024,
}
