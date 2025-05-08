from datetime import datetime, timedelta
from functools import wraps
from inspect import signature

import jwt
from flask import abort, current_app, jsonify, request


from models.user import User

# - TOKEN FUNCTIONS
##################
# JWT from https://www.youtube.com/watch?v=WxGBoY5iNXY


def generate_token(user: User):
    token = jwt.encode(
        {"public_id": user.public_id, "exp": datetime.utcnow() + timedelta(weeks=1)},
        current_app.config["SECRET_KEY"],
        algorithm="HS256",
    )
    return token


def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):

        token = request.headers.get("x-access-token")
        if not token:
            return jsonify({"message": "Token fehlt!"}), 401

        try:
            data = jwt.decode(
                token, current_app.config["SECRET_KEY"], algorithms="HS256"
            )
            current_user = current_app.cache.get(data["public_id"])
            if current_user is None:
                current_user = User.query.filter_by(public_id=data["public_id"]).first()
                if current_user is None:
                    abort(401, "Konto existiert nicht oder wurde gelöscht!")
                current_app.cache.set(data["public_id"], current_user, timeout=60 * 60)

        except jwt.ExpiredSignatureError:
            abort(401, "Token ist abgelaufen!")
        except jwt.InvalidTokenError:
            abort(401, "Token nicht (mehr) gültig!")

        if "current_user" in signature(f).parameters:
            kwargs["current_user"] = current_user

        return f(*args, **kwargs)

    return decorated
