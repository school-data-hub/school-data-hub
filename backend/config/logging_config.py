import logging

from flask import request


class RequestHeadersHandler(logging.Handler):
    def emit(self, record):
        if request:
            record.request_headers = dict(request.headers)
        else:
            record.request_headers = {}


# - TODO: FINISH IMPLEMENTING LOGGING


def setup_logging(app):
    gunicorn_logger = logging.getLogger("gunicorn.error")
    app.logger.handlers = gunicorn_logger.handlers
    request_headers_handler = RequestHeadersHandler()
    # TODO: FINISH IMPLEMENTING LOGGING
    handler = logging.FileHandler(
        # "/home/admin/schuldaten_hub/schuldaten_hub.log"
        "schuldaten_hub.log"
    )  # errors logged to this file
    formatter = logging.Formatter(
        "%(asctime)s %(levelname)s:\n%(message)s [in %(pathname)s:%(lineno)d]"
    )
    handler.setFormatter(formatter)
    handler.setLevel(logging.DEBUG)  # only log errors and above
    app.logger.addHandler(handler)  # attach the handler to the app's logger
    request_headers_handler = RequestHeadersHandler()
    request_headers_formatter = logging.Formatter(
        "%(asctime)s %(levelname)s:\n%(message)s [in %(pathname)s:%(lineno)d]\nHeaders: %(request_headers)s"
    )
    request_headers_handler.setFormatter(request_headers_formatter)
    request_headers_handler.setLevel(logging.DEBUG)
    app.logger.addHandler(request_headers_handler)
    # handler = RotatingFileHandler("error.log", maxBytes=10000, backupCount=1)
    # handler.setLevel(logging.ERROR)
    # formatter = logging.Formatter(
    #     "%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]"
    # )
    # handler.setFormatter(formatter)
    # app.logger.addHandler(handler)
