#!/usr/bin/env python3
"""Fake Arbox server for the executor tests. Test-only, stdlib only.

Usage: fake_server.py PORT_FILE LOG_FILE

Binds 127.0.0.1 on a free port, writes the port to PORT_FILE, and appends one
tab-separated line per request to LOG_FILE:
    N <TAB> METHOD <TAB> PATH <TAB> QUERY <TAB> API_KEY <TAB> BODY_FILE
Request bodies are stored next to the log as <LOG_FILE>.body.<N>.

Routes live under /api/public (the real base path). Special keys:
    bad-*        -> 401 Unauthenticated
    forbidden-*  -> 403
    busy-*       -> 429 on every request
GET /v3/busy?fail=N&run=R answers 429 to the first N requests with the same query, then 200.
"""
import json
import os
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlsplit

PREFIX = "/api/public"
DEMO_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "skills", "arbox-api", "assets", "demo")
PORT_FILE, LOG_FILE = sys.argv[1], sys.argv[2]
LOCK = threading.Lock()
COUNTER = [0]
BUSY_HITS = {}
TOTAL_USERS = 1200


def envelope(rows):
    return {"statusCode": 200, "data": rows, "extra": []}


def user_rows(page, limit):
    start = (page - 1) * limit
    end = min(start + limit, TOTAL_USERS)
    return [{"user_id": str(n), "first_name": "User%d" % n} for n in range(start + 1, end + 1)]


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.0"

    def log_message(self, *args):
        pass

    def reply(self, status, payload, raw=False, content_type=None):
        body = payload if raw else json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
        data = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type or ("text/plain" if raw else "application/json"))
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def handle_any(self):
        parts = urlsplit(self.path)
        length = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(length).decode("utf-8", "replace") if length else ""
        key = self.headers.get("api-key", "")
        with LOCK:
            COUNTER[0] += 1
            n = COUNTER[0]
            body_file = "%s.body.%d" % (LOG_FILE, n)
            with open(body_file, "w") as fh:
                fh.write(body)
            with open(LOG_FILE, "a") as fh:
                fh.write("%d\t%s\t%s\t%s\t%s\t%s\n" % (n, self.command, parts.path, parts.query, key, body_file))
        if not parts.path.startswith(PREFIX + "/"):
            return self.reply(404, {"message": "wrong base path"})
        route = parts.path[len(PREFIX):]
        query = parse_qs(parts.query)
        if route == "/v3/echo401":
            return self.reply(401, {"message": "Unauthenticated.", "echo": dict(self.headers.items())})
        if route == "/v3/boom":
            return self.reply(500, "internal error; request headers were:\n%s" % self.headers, raw=True)
        if not key or key.startswith("bad-"):
            return self.reply(401, {"message": "Unauthenticated."})
        if key.startswith("forbidden-"):
            return self.reply(403, {"message": "This action is unauthorized."})
        if key.startswith("busy-"):
            return self.reply(429, {"message": "concurrent requests not allowed"})
        if route == "/v3/busy":
            with LOCK:
                BUSY_HITS[parts.query] = BUSY_HITS.get(parts.query, 0) + 1
                hits = BUSY_HITS[parts.query]
            if hits <= int((query.get("fail") or ["0"])[0]):
                return self.reply(429, {"message": "concurrent requests not allowed"})
            return self.reply(200, envelope([{"hits": hits}]))
        if route == "/v3/slow":
            time.sleep(3)
            return self.reply(200, envelope([]))
        if route == "/v3/notfound":
            return self.reply(404, {"statusCode": 404, "error": {"code": "NOT_FOUND", "message": "Resource not found"}, "data": None})
        if route == "/v3/422":
            return self.reply(422, {"message": "The given data was invalid.", "errors": {"phone": ["The phone field is required."]}})
        if route == "/v3/locations" and self.command == "GET" and key.startswith("heb-"):
            # Like PHP's json_encode: every non-ASCII character as a \\uXXXX escape, emoji as a surrogate pair.
            rows = [{"location_id": "1", "location_name": "סטודיו דמו"}, {"location_id": "2", "location_name": "Café \U0001F3CB"}]
            return self.reply(200, json.dumps(envelope(rows), ensure_ascii=True, separators=(",", ":")), raw=True, content_type="application/json")
        if route == "/v3/locations" and self.command == "GET":
            return self.reply(200, envelope([{"location_id": "7", "location_name": "Studio Flow", "address": "1 Test St"}]))
        if route == "/v3/params":
            return self.reply(200, envelope([{k: v[0] for k, v in query.items()}]))
        if route == "/v3/empty":
            return self.reply(200, envelope([]))
        if route == "/v3/endless":
            limit = int((query.get("limit") or ["100"])[0])
            return self.reply(200, envelope([{"n": i} for i in range(limit)]))
        if route == "/v3/users" and self.command == "GET":
            page = int((query.get("page") or ["1"])[0])
            limit = min(int((query.get("limit") or ["100"])[0]), 500)
            return self.reply(200, envelope(user_rows(page, limit)))
        if self.command == "GET":
            # Same fixtures as `arbox read --demo`: /v3/a/b -> v3__a__b.json, page > 1 is empty.
            fixture = os.path.join(DEMO_DIR, route.lstrip("/").replace("/", "__") + ".json")
            if os.path.isfile(fixture):
                if int((query.get("page") or ["1"])[0]) > 1:
                    return self.reply(200, envelope([]))
                with open(fixture, encoding="utf-8") as fh:
                    return self.reply(200, fh.read(), raw=True, content_type="application/json")
        if self.command in ("POST", "PATCH", "DELETE"):
            return self.reply(200, envelope([]))
        return self.reply(404, {"message": "No query results for route " + route})

    do_GET = do_POST = do_PATCH = do_DELETE = do_PUT = handle_any


server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
with open(PORT_FILE, "w") as fh:
    fh.write(str(server.server_address[1]))
server.serve_forever()
