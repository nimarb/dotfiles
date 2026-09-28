#!/usr/bin/env python3
r"""Rebuild broken duplicated history snapshots into JSONL

Run from the dotfiles directory. Supports mac/linux
Reload sessions still using the old logger so legacy files stop changing.

1. Build a separate archive from ~/.logs; originals remain untouched:

   uv run --no-project shell/rebuild-history-logs.py build

2. Review the summary, then install the rebuilt archive into ~/.logs and move
   the original legacy files into a backup (existing JSONL files stay untouched):

   uv run --no-project shell/rebuild-history-logs.py install

3. Check the file at the "installed" path printed by install: inspect a few
   recovered commands and confirm the archive looks right. Open a fresh terminal,
   run a harmless command, and confirm the new logger writes a session JSONL file
   under ~/.logs. Installation already verified the archive and original hashes.

4. Finish cleanup once satisfied: remove the build directory and, if you no longer
   need the originals, the backup. Replace <id> below with the actual backup suffix
   from "originals_backup" printed by install; use your chosen paths if overridden:

   rm -r "$HOME/.logs-rebuilt"
   rm -r "$HOME/.logs-originals-<id>"

   Removing the backup permanently deletes the originals and reclaims their disk
   space. Keep or move it elsewhere if you still want the original evidence.
   Leave ~/.logs in place: it contains the installed archive and ongoing logs.

Defaults: source ~/.logs, output ~/.logs-rebuilt, backup ~/.logs-originals-<id>.
Output and backup are siblings of the source, including with a custom --source.
To process another archive, pass --source /path/to/.logs to both steps.
Override paths with --output (both steps) or --backup (install only). Output and
backup directories must not already exist when created; nothing is overwritten.
The default deduplication removes repeated snapshots, preserving distinguishable
executions. Build and install preserve originals; removing the backup reclaims
their disk space.

Python 3.8+, standard library only. See docs/shell-history-migration.md.
Without uv, replace "uv run --no-project" with "python3" in either command.
"""

import argparse
import base64
from collections import OrderedDict
from datetime import date
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import sqlite3
import sys
import tempfile
import uuid


LEGACY_NAME = re.compile(r"(zsh|bash)-history-(\d{4}-\d{2}-\d{2})\.log\Z")
STAMP = rb"\d{4}-\d{2}-\d{2}\.\d{2}:\d{2}:\d{2}"
# Validate padding during the match so ordinary numbers inside a directory name
# do not stop the search before the actual history field.
HEADER_FIELD = rb"(?= {5}\d[ *] | {4}\d{2}[ *] | {3}\d{3}[ *] | {2}\d{4}[ *] | \d{5,}[ *] )"
HEADER = re.compile(rb"^(" + STAMP + rb") (/.*?)" + HEADER_FIELD + rb"( {1,5})(\d+)([ *]) (.*)$", re.DOTALL)
ROW = re.compile(rb"^( {0,4})(\d+)([ *]) (.*)$", re.DOTALL)
BASH_TIME = re.compile(rb"^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}): (.*)$", re.DOTALL)
MAX_ENTRY = 64 * 1024 * 1024
CACHE_SIZE = 50000


class MigrationError(Exception):
    pass


def encode(value):
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def text(value):
    return value.decode("utf-8", "replace")


def file_hash(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def signature(stat):
    return stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns


def inventory(source, before=None):
    result = []
    for path in sorted(source.iterdir()):
        match = LEGACY_NAME.fullmatch(path.name)
        if not match or (before and match[2] >= before):
            continue
        if path.is_symlink() or not path.is_file():
            raise MigrationError("legacy input must be a regular, non-symlink file: " + path.name)
        date.fromisoformat(match[2])
        result.append((path, match[1]))
    return result


def validate_locations(source, output, backup=None):
    locations = [source, output] + ([backup] if backup else [])
    for i, left in enumerate(locations):
        for right in locations[i + 1:]:
            if left == right or left in right.parents or right in left.parents:
                raise MigrationError("source, output and backup must be separate directories, not nested")


def display_padding(spaces, number, header=False):
    # Both legacy commands right-align the event number in a five-column field.
    return len(spaces) == max(0, 5 - len(number)) + int(header)


def entries(path, shell, manifest_item):
    """Yield rendered entries. Snapshot times/cwds are observations, not executions."""
    initial = path.stat()
    digest = hashlib.sha256()
    snapshot = None
    prefix = hashlib.sha256(b"legacy-zsh-history-prefix-v1").digest()
    pending = None
    consumed = 0

    def finish():
        nonlocal prefix, pending
        if pending is None:
            return None
        number, offset, pieces, length = pending
        raw = b"".join(pieces)
        if raw.endswith(b"\n"):
            raw = raw[:-1]
        native_time = None
        if shell == "bash" and number is not None:
            match = BASH_TIME.match(raw)
            if match:
                native_time, raw = text(match[1]), match[2]
        if number is None:
            # Unknown material has no trustworthy history identity. Preserve each
            # source occurrence instead of guessing that equal text is a replay.
            identity = hashlib.sha256(b"unparsed\0" + encode([path.name, offset]).encode() + b"\0" + raw).digest()
        elif shell == "zsh":
            prefix = hashlib.sha256(prefix + str(number).encode() + b"\0" + raw).digest()
            identity = prefix
        else:
            # Bash logged only its last entry. Scope identity to one source day;
            # include its native timestamp when present to distinguish executions.
            identity = hashlib.sha256(encode([path.name, number, native_time]).encode() + b"\0" + raw).digest()
        observation = snapshot or {"file": path.name, "byte_offset": None, "time_local": None, "cwd": None}
        result = (identity, shell, number, raw, native_time, observation, offset)
        pending = None
        return result

    with path.open("rb") as stream:
        if signature(os.fstat(stream.fileno())) != signature(initial):
            raise MigrationError("input changed before reading: " + path.name)
        while consumed < initial.st_size:
            offset = consumed
            line = stream.readline(min(MAX_ENTRY + 1, initial.st_size - consumed))
            if not line:
                raise MigrationError("input was truncated: " + path.name)
            consumed += len(line)
            digest.update(line)
            header = HEADER.match(line)
            if header and display_padding(header[3], header[4], header=True):
                entry = finish()
                if entry:
                    yield entry
                snapshot = {"file": path.name, "byte_offset": offset,
                            "time_local": text(header[1]), "cwd": text(header[2])}
                prefix = hashlib.sha256(b"legacy-zsh-history-prefix-v1").digest()
                pending = (int(header[4]), offset, [header[6]], len(header[6]))
            else:
                row = ROW.match(line) if shell == "zsh" and snapshot else None
                if row and display_padding(row[1], row[2]):
                    entry = finish()
                    if entry:
                        yield entry
                    pending = (int(row[2]), offset, [row[4]], len(row[4]))
                elif pending is not None:
                    number, first_offset, pieces, length = pending
                    pieces.append(line)
                    pending = (number, first_offset, pieces, length + len(line))
                else:
                    # Unknown leading material remains recoverable as its own row.
                    pending = (None, offset, [line], len(line))
            if pending[3] > MAX_ENTRY:
                raise MigrationError("entry exceeds 64 MiB; input retained unchanged: " + path.name)
        entry = finish()
        if entry:
            yield entry
        if signature(os.fstat(stream.fileno())) != signature(initial):
            raise MigrationError("input changed during rebuild; reload old shells and retry: " + path.name)
    if signature(path.stat()) != signature(initial):
        raise MigrationError("input was replaced during rebuild: " + path.name)
    manifest_item.update(name=path.name, bytes=consumed, sha256=digest.hexdigest())


class Index:
    """Disk-backed identities, with a bounded cache for repeated snapshot prefixes."""

    def __init__(self, path, mode):
        self.db = sqlite3.connect(str(path))
        self.db.execute("CREATE TABLE entries (id BLOB PRIMARY KEY, record TEXT NOT NULL, sightings INTEGER NOT NULL DEFAULT 0, last_observation TEXT)")
        self.cache = OrderedDict()
        self.mode = mode
        self.observations = 0

    def flush_one(self, key, value):
        count, observation = value
        if count:
            self.db.execute("UPDATE entries SET sightings=sightings+?, last_observation=? WHERE id=?",
                            (count, encode(observation), key))
            value[0] = 0

    def add(self, entry):
        identity, shell, number, raw, native_time, snapshot, offset = entry
        if self.mode == "command" and number is not None:
            identity = hashlib.sha256(b"command\0" + raw).digest()
        observation = {"snapshot": snapshot, "entry_byte_offset": offset}
        cached = self.cache.get(identity)
        if cached is None:
            if len(self.cache) >= CACHE_SIZE:
                key, value = self.cache.popitem(last=False)
                self.flush_one(key, value)
            record = {"v": 1, "kind": "legacy_history" if number is not None else "unparsed_legacy",
                      "shell": shell, "time": None, "cwd": None, "session": None, "seq": None,
                      "timing": "legacy_observation", "command": text(raw),
                      "legacy": {"rendered_text": True, "history_number": number,
                                 "history_time_local": native_time, "first_observation": observation}}
            if raw.decode("utf-8", "replace").encode("utf-8") != raw:
                record["legacy"]["raw_base64"] = base64.b64encode(raw).decode("ascii")
            self.db.execute("INSERT OR IGNORE INTO entries (id, record) VALUES (?, ?)", (identity, encode(record)))
            cached = [0, observation]
            self.cache[identity] = cached
        self.cache.move_to_end(identity)
        cached[0] += 1
        cached[1] = observation
        self.observations += 1

    def flush(self):
        for key, value in self.cache.items():
            self.flush_one(key, value)
        self.db.commit()

    def export(self, path):
        self.flush()
        count = unknown = 0
        with path.open("x", encoding="utf-8", newline="\n") as stream:
            for key, payload, sightings, last in self.db.execute("SELECT id, record, sightings, last_observation FROM entries ORDER BY rowid"):
                record = json.loads(payload)
                record["legacy"].update(identity=key.hex(), observations=sightings,
                                        last_observation=json.loads(last))
                stream.write(encode(record) + "\n")
                count += 1
                unknown += record["kind"] == "unparsed_legacy"
        return count, unknown


def source_and_output(args):
    source = args.source.expanduser().resolve()
    output = args.output if args.output is not None else source.with_name(source.name + "-rebuilt")
    return source, output.expanduser().resolve()


def build(args):
    source, output = source_and_output(args)
    validate_locations(source, output)
    inputs = inventory(source, args.before)
    if not inputs:
        raise MigrationError("no matching legacy .log files; JSONL and other files are intentionally untouched")
    if output.exists():
        raise MigrationError("output already exists; use a new directory")
    output.mkdir(mode=0o700)
    marker = output / "INCOMPLETE"
    marker.write_text("Build is incomplete. Inputs have not been modified.\n", encoding="utf-8")
    index_path = output / ".rebuild-index.sqlite"
    index = Index(index_path, args.dedupe)
    manifest = {"v": 1, "id": uuid.uuid4().hex, "source": str(source),
                "dedupe": args.dedupe, "before": args.before, "inputs": []}
    try:
        for position, (path, shell) in enumerate(inputs, 1):
            item = {}
            for entry in entries(path, shell, item):
                index.add(entry)
            manifest["inputs"].append(item)
            index.flush()
            if position % 10 == 0 or position == len(inputs):
                print(f"Read {position}/{len(inputs)} legacy files", file=sys.stderr, flush=True)
        archive = output / ("legacy-history-rebuilt-" + manifest["id"] + ".jsonl")
        records, unknown = index.export(archive)
        manifest["archive"] = {"name": archive.name, "bytes": archive.stat().st_size, "sha256": file_hash(archive)}
        manifest["summary"] = {"input_files": len(inputs), "input_bytes": sum(x["bytes"] for x in manifest["inputs"]),
                               "observations": index.observations, "recovered_records": records,
                               "collapsed_observations": index.observations - records, "unparsed_records": unknown,
                               "output_bytes": archive.stat().st_size}
        (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
        marker.unlink()
        print(json.dumps({"output": str(output), **manifest["summary"]}, indent=2))
    finally:
        index.db.close()
    index_path.unlink()


def install(args):
    source, output = source_and_output(args)
    if (output / "INCOMPLETE").exists():
        raise MigrationError("cannot install an incomplete build")
    manifest = json.loads((output / "manifest.json").read_text(encoding="utf-8"))
    if manifest.get("v") != 1 or not re.fullmatch(r"[0-9a-f]{32}", manifest.get("id", "")):
        raise MigrationError("unsupported or invalid manifest")
    backup = args.backup.expanduser().resolve() if args.backup else source.with_name(source.name + "-originals-" + manifest["id"][:8])
    validate_locations(source, output, backup)
    if backup.exists():
        raise MigrationError("backup already exists; inspect it before retrying an interrupted install")
    expected_name = "legacy-history-rebuilt-" + manifest["id"] + ".jsonl"
    if manifest["archive"]["name"] != expected_name:
        raise MigrationError("invalid archive filename in manifest")
    archive, target = output / expected_name, source / expected_name
    if archive.is_symlink() or file_hash(archive) != manifest["archive"]["sha256"]:
        raise MigrationError("rebuilt archive changed after verification")
    if target.exists():
        raise MigrationError("rebuilt archive is already present in source")
    inputs = manifest["inputs"]
    if not inputs or any(not LEGACY_NAME.fullmatch(item["name"]) for item in inputs):
        raise MigrationError("invalid input filenames in manifest")
    current = {path.name for path, _ in inventory(source, manifest["before"])}
    if current != {item["name"] for item in inputs}:
        raise MigrationError("legacy input set changed; make a fresh build")
    print("Verifying every original against the build manifest…", file=sys.stderr, flush=True)
    for item in inputs:
        path = source / item["name"]
        if path.stat().st_size != item["bytes"] or file_hash(path) != item["sha256"]:
            raise MigrationError("original changed after build; reload old shells and rebuild: " + item["name"])
    # Rename originals only on one filesystem. No copy-and-delete fallback.
    backup.mkdir(mode=0o700)
    if backup.stat().st_dev != source.stat().st_dev:
        backup.rmdir()
        raise MigrationError("backup must be on the same filesystem as source")
    (backup / "migration-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    # Publish a verified complete file without overwriting any existing pathname.
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=source, prefix=".history-rebuild-", delete=False) as stream:
            temporary = Path(stream.name)
            with archive.open("rb") as original:
                shutil.copyfileobj(original, stream)
            stream.flush()
            os.fsync(stream.fileno())
        if file_hash(temporary) != manifest["archive"]["sha256"]:
            raise MigrationError("archive changed while publishing; originals were not moved")
        os.link(temporary, target)
        for item in inputs:
            os.rename(source / item["name"], backup / item["name"])
        for item in inputs:
            if file_hash(backup / item["name"]) != item["sha256"]:
                raise MigrationError("a legacy writer remained active; originals are preserved in backup, inspect before proceeding")
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    print(json.dumps({"installed": str(target), "originals_backup": str(backup),
                      "new_jsonl_files": "untouched", "originals_deleted": False}, indent=2))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    actions = parser.add_subparsers(dest="action", required=True)
    for name, help_text in [("build", "read legacy logs; write a separate rebuilt archive"),
                            ("install", "verify, install rebuilt JSONL, and move originals to a backup")]:
        command = actions.add_parser(name, help=help_text)
        command.add_argument("--source", type=Path, default=Path("~/.logs"), help="legacy archive directory (default: ~/.logs)")
        command.add_argument("--output", type=Path, help="rebuilt archive directory (default: <source>-rebuilt beside source)")
        if name == "build":
            command.add_argument("--before", type=lambda x: date.fromisoformat(x).isoformat(), help="only filenames dated before YYYY-MM-DD")
            command.add_argument("--dedupe", choices=("history", "command"), default="history",
                                 help="history preserves distinguishable repeats; command keeps the first rendered command text")
        else:
            command.add_argument("--backup", type=Path, help="originals backup directory (default: <source>-originals-<id> beside source)")
    args = parser.parse_args(argv)
    os.umask(0o077)
    try:
        (build if args.action == "build" else install)(args)
    except (MigrationError, OSError, ValueError, KeyError, TypeError, sqlite3.Error) as error:
        print("history rebuild: " + str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
