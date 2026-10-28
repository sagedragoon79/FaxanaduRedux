#!/usr/bin/env python3
"""Calls the PixelLab API (https://api.pixellab.ai/v2) and saves the images it returns.

The token is never committed. In the cloud environment it is a network secret for api.pixellab.ai
(Bearer, header Authorization) that the proxy adds to every request, so no header is sent here.
Elsewhere, set PIXELLAB_API_KEY and it is sent as the Bearer token. Every POST is logged in art/pixellab-ledger.csv with what it cost, as
Autosprite calls are in art/autosprite-ledger.csv. Endpoints, parameters and enum values are in
https://api.pixellab.ai/v2/llms.txt and the OpenAPI spec it links.

Usage:
  python3 tools/art/pixellab.py balance
  python3 tools/art/pixellab.py post <endpoint> <request.json|-> <out_dir> [note]
      POST a request; an async job is polled until done. Every image in the result is written to
      art/pixellab/<out_dir>/ as 00.png, 01.png ... and the raw result (base64 stripped) as result.json
      (an async call also keeps its first answer, with the new character or object id, as queued.json).
  python3 tools/art/pixellab.py job <job_id> <out_dir>
      Fetch (and wait on) a background job started earlier, saving its images the same way.
  python3 tools/art/pixellab.py get <path>
      GET any read-only endpoint (characters, tilesets ...) and print the JSON.

Example (a 32 px image, the cheapest kind of call):
  echo '{"description": "red apple", "image_size": {"width": 32, "height": 32}, "no_background": true}' \\
    | python3 tools/art/pixellab.py post create-image-pixflux - test/apple "connection test"
"""
import base64
import csv
import datetime
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCES = ROOT / "art" / "pixellab"
LEDGER = ROOT / "art" / "pixellab-ledger.csv"
BASE = "https://api.pixellab.ai/v2"
POLL_SECONDS = 5
POLL_LIMIT = 600


def request(method, path, body=None):
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    if os.environ.get("PIXELLAB_API_KEY"):
        headers["Authorization"] = f"Bearer {os.environ['PIXELLAB_API_KEY']}"
    req = urllib.request.Request(
        f"{BASE}/{path.lstrip('/')}",
        method=method,
        data=None if body is None else json.dumps(body).encode(),
        headers=headers,
    )
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            return json.loads(r.read() or b"{}")
    except urllib.error.HTTPError as e:
        if e.code == 401:
            sys.exit(f"{method} /{path}: HTTP 401: no PixelLab token (add the api.pixellab.ai network secret, "
                     "or set PIXELLAB_API_KEY)")
        sys.exit(f"{method} /{path}: HTTP {e.code}: {e.read().decode(errors='replace')[:2000]}")


def job_ids_of(result):
    if result.get("background_job_ids"):
        return list(result["background_job_ids"])
    return [result["background_job_id"]] if result.get("background_job_id") else []


def wait(job_id):
    for _ in range(POLL_LIMIT // POLL_SECONDS):
        job = request("GET", f"background-jobs/{job_id}")
        if job.get("status") == "completed":
            return job
        if job.get("status") == "failed":
            sys.exit(f"job {job_id} failed: {json.dumps(job.get('last_response'))[:2000]}")
        time.sleep(POLL_SECONDS)
    sys.exit(f"job {job_id} still running after {POLL_LIMIT} s; fetch it later with: job {job_id} <out_dir>")


def extract_images(node, found):
    """Replaces every {"base64": ...} image in the result with its file name, collecting the bytes."""
    if isinstance(node, dict):
        if isinstance(node.get("base64"), str):
            name = f"{len(found):02d}.{node.get('format', 'png')}"
            found.append((name, base64.b64decode(node["base64"])))
            return name
        return {k: extract_images(v, found) for k, v in node.items()}
    if isinstance(node, list):
        return [extract_images(v, found) for v in node]
    return node


def save(result, out_dir):
    dest = SOURCES / out_dir
    dest.mkdir(parents=True, exist_ok=True)
    images = []
    stripped = extract_images(result, images)
    for name, data in images:
        (dest / name).write_bytes(data)
    (dest / "result.json").write_text(json.dumps(stripped, indent=1) + "\n")
    print(f"{dest.relative_to(ROOT)}: {len(images)} image(s)")
    return len(images)


def cost(result):
    usage = result.get("usage") or {}
    if usage.get("type") == "generations":
        return f"{usage.get('generations')} generations"
    return f"${usage['usd']}" if usage.get("usd") is not None else "?"


def log(endpoint, out_dir, spent, outcome, note):
    new = not LEDGER.exists()
    with LEDGER.open("a", newline="") as f:
        w = csv.writer(f)
        if new:
            w.writerow(["date", "endpoint", "out_dir", "cost", "result", "notes"])
        w.writerow([datetime.date.today().isoformat(), endpoint, out_dir, spent, outcome, note])


def main():
    args = sys.argv[1:]
    if args[:1] == ["balance"]:
        print(json.dumps(request("GET", "balance"), indent=1))
    elif args[:1] == ["get"] and len(args) == 2:
        print(json.dumps(request("GET", args[1]), indent=1))
    elif args[:1] == ["job"] and len(args) == 3:
        save(wait(args[1]), args[2])
    elif args[:1] == ["post"] and len(args) in (4, 5):
        endpoint, src, out_dir = args[1].lstrip("/"), args[2], args[3]
        body = json.load(sys.stdin if src == "-" else open(src))
        note = args[4] if len(args) == 5 else ""
        result = request("POST", endpoint, body)
        jobs = job_ids_of(result)
        if not jobs:
            n = save(result, out_dir)
            log(endpoint, out_dir, cost(result), f"ok, {n} image(s)", note)
            return
        # The queued answer carries the new character/object/tileset id; keep it beside the images.
        save(result, out_dir)
        (SOURCES / out_dir / "result.json").rename(SOURCES / out_dir / "queued.json")
        log(endpoint, out_dir, cost(result), "queued " + " ".join(jobs), note)
        for i, job in enumerate(jobs):
            print(f"waiting on job {job}")
            save(wait(job), out_dir if len(jobs) == 1 else f"{out_dir}/{i:02d}")
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
