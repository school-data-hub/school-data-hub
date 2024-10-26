from datetime import datetime

from flask import json

from models.log_entry import LogEntry
from models.shared import db
from models.user import User


def create_log_entry(user: User, request, data):
    log_datetime = datetime.strptime(
        datetime.now().strftime("%Y-%m-%d %H:%M:%S"), "%Y-%m-%d %H:%M:%S"
    )
    user_name = user.name
    endpoint = request.method + ": " + request.path

    payload = json.dumps(data, indent=None, sort_keys=True)

    new_log_entry = LogEntry(
        datetime=log_datetime, user=user_name, endpoint=endpoint, payload=payload
    )

    db.session.add(new_log_entry)
    return
