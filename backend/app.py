import sys
import uuid

import flask
from apiflask import APIFlask
from apiflask.ui_templates import elements_template, rapidoc_template, redoc_template
from flask import render_template_string
from flask_caching import Cache
from flask_migrate import Migrate
from werkzeug.security import generate_password_hash

from config.blueprints import register_blueprints
from config.logging_config import setup_logging
from config.open_api_config import open_api_config
from config.sqlalchemy_config import sqlalchemy_config
from models.shared import db
from models.user import User
from sse_announcer import announcer, format_sse

# - INIT APP

app = APIFlask(__name__)
app.config["DEBUG"] = False
cache = Cache(app, config={"CACHE_TYPE": "simple"})
app.cache = cache

# - Apply open api config
app.config.update(open_api_config)

# - Apply sqlalchemy config
app.config.update(sqlalchemy_config)

# - LOGGING CONFIG
setup_logging(app)

# - FILE UPLOAD CONFIG
ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png"}
app.config["UPLOAD_FOLDER"] = "./media_upload"
app.config["ALLOWED_EXTENSIONS"] = ALLOWED_EXTENSIONS
app.config["UPLOAD_EXTENSIONS"] = [".jpg", ".jpeg", ".png"]


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower in ALLOWED_EXTENSIONS


# - INIT SSE SERVER
# def start_sse_server():
#     sse_process = Process(target=start_sse)
#     sse_process.start()
#     return sse_process

# - Test SSE when app starts
msg = format_sse(data="pong", event="test")
announcer.announce(msg=msg)
# sse_process = start_sse_server()
# announcer = SSEManager(address=("127.0.0.1", 2437), authkey=b"sse")
# announcer.connect()
# announcer.sse_announce(format_sse("Hello, world!"))

# - BLUEPRINTS

register_blueprints(app)

# - OPEN API DOC ROUTES


@app.route("/redoc")
def my_redoc():
    return render_template_string(
        redoc_template, title="School Data Hub", version="1.0"
    )


@app.route("/elements")
def my_elements():
    return render_template_string(
        elements_template, title="School Data Hub", version="1.0"
    )


@app.route("/rapidoc")
def my_rapidoc():
    return render_template_string(
        rapidoc_template, title="School Data Hub", version="1.0"
    )


# - ERROR HANDLER ROUTE


@app.errorhandler(500)
def internal_server_error(error):
    app.logger.error("Server Error: %s", error, exc_info=True)
    return "An internal server error occurred.", 500


# - SSE ROUTE


# @token_required #- TODO: implement token_required
@app.route("/api/listen", methods=["GET"])
def listen():

    def stream():
        messages = announcer.listen()  # returns a queue.Queue
        print("stream method called", file=sys.stderr)
        while True:
            msg = messages.get()  # blocks until a new message arrives
            yield msg

    return flask.Response(stream(), mimetype="text/event-stream")


# - RUN SERVER

# db.init_app(app) because of https://stackoverflow.com/questions/9692962/flask-sqlalchemy-import-context-issue/9695045#9695045
migrate = Migrate(app, db)
db.init_app(app)
with app.app_context():
    db.create_all()
    # - if the database exists, check if there is a user "admin" - if not, create one
    # - this will create an admin user "ADM" with the password "admin"
    # - USE ONLY FOR TESTING!
    # if User.query.filter_by(role="admin").first() is None:
    #     password = generate_password_hash("admin", method="scrypt")
    #     user = User(
    #         public_id=str(uuid.uuid4().hex),
    #         name="ADM",
    #         password=password,
    #         admin=True,
    #         role="admin",
    #         credit=50,
    #         time_units=0,
    #         tutoring=None,
    #         contact=None,
    #     )
    #     db.session.add(user)
    #     db.session.commit()
if __name__ == "__main__":
    app.run(host="192.168.178.107")
    # app.run(host='0.0.0.0')
