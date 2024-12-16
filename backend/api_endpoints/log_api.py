import os

from flask import Blueprint, abort, current_app, request, send_file
from werkzeug.utils import secure_filename

log_api = Blueprint("log_api", __name__)

LOG_FILE_PATH = "schuldaten_hub.log"


@log_api.route("/log/download", methods=["GET"])
def download_log():
    try:
        with open(LOG_FILE_PATH, "r") as log_file:
            log_content = log_file.read()
        print(log_content)
        return {"log": log_content}, 200

    except Exception as e:
        abort(500, description=f"Error downloading log file: {str(e)}")


@log_api.route("/log/upload", methods=["POST"])
def upload_log():
    if "file" not in request.files:
        abort(400, description="No file part in the request")

    file = request.files["file"]
    if file.filename == "":
        abort(400, description="No selected file")

    if file and file.filename == secure_filename(LOG_FILE_PATH):
        file.save(os.path.join(current_app.root_path, LOG_FILE_PATH))
        return {"message": "Log file uploaded successfully"}, 200
    else:
        abort(400, description="Invalid file")
