## https://maxhalford.github.io/blog/flask-sse-no-deps/
import queue
import sys
from multiprocessing import Lock
from multiprocessing.managers import BaseManager


class MessageAnnouncer:

    def __init__(self):
        self.listeners = []

    def listen(self):
        self.listeners.append(queue.Queue(maxsize=5))
        return self.listeners[-1]

    def announce(self, msg):
        # We go in reverse order because we might have to delete an element, which will shift the
        # indices backward
        for i in reversed(range(len(self.listeners))):
            try:
                self.listeners[i].put_nowait(msg)
                print("Message sent to listener {i}", file=sys.stderr)
            except queue.Full:
                del self.listeners[i]
            except Exception as e:
                from app import app

                app.logger.error(e, exc_info=True)


def format_sse(data: str, event=None) -> str:
    """Formats a string and an event name in order to follow the event stream convention.

    >>> format_sse(data=json.dumps({'abc': 123}), event='Jackson 5')
    'event: Jackson 5\\ndata: {"abc": 123}\\n\\n'

    """
    msg = f"data: {data}\n\n"
    if event is not None:
        msg = f"event: {event}\n{msg}"
    return msg


announcer = MessageAnnouncer()
# class SSEManager(BaseManager):
#     pass


# def start_sse():
#     lock = Lock()
#     sse = MessageAnnouncer()

#     def sse_listen():
#         with lock:
#             return sse.listen()

#     def sse_announce(item):
#         with lock:
#             sse.announce(item)

#     SSEManager.register("sse_listen", sse_listen)
#     SSEManager.register("sse_announce", sse_announce)

#     manager = SSEManager(address=("127.0.0.1", 2437), authkey=b"sse")
#     server = manager.get_server()
#     server.serve_forever()


# def import_sse():
#     SSEManager.register("sse_listen")
#     SSEManager.register("sse_announce")


# if __name__ == "__main__":
#     start_sse()
# else:
#     import_sse()
