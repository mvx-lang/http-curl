#!/bin/sh
# http-curl — stage the package into $1, for every platform's artifact.
# Copyright (C) 2026 Gordon Heydon.  GPL-2.0-only (see LICENSE).
#
#   sh build-pkg.sh <stagedir>
#
# SOURCE, on every platform.  There is no native code here at all: this package
# is the HTTP API, and every platform-shaped thing it needs -- the shell
# quoting, jBASE having no shell, UniVerse needing SH -c -- lives in the curl
# transport underneath, which it depends on rather than reimplements.  So the
# artifacts are `<sys>-any-any-le`: nothing is compiled, so there is nothing to
# lock to an os or arch.
set -e
STAGE="${1:?usage: build-pkg.sh <stagedir>}"
SRC="$(cd "$(dirname "$0")" && pwd)"
ACCT="$STAGE/http-curl"

mkdir -p "$ACCT/BP"
# Derived from the directory, never a hardcoded list: a hardcoded one silently
# drops a newly added program, which is how CMD.FLAG went missing from a cmd
# release and `GIT` then failed with "Cannot find CMD.FLAG".
for f in "$SRC"/BP/*; do
   [ -f "$f" ] || continue
   case "$(basename "$f")" in (_*|\$*|.*) continue ;; esac
   cp "$f" "$ACCT/BP/"
done

# EVERY STAGED SOURCE GETS A TRAILING NEWLINE.  UniVerse's compiler rejects a
# source whose last line is unterminated -- "End of File unexpected, Was
# expecting: ';', End of Line" -- so without this the uv artifact cannot be
# compiled on the target at all, and the package installs as a directory of
# sources that never become programs.  Appending only when it is missing keeps
# re-staging idempotent.
for f in "$ACCT"/BP/*; do
   [ -f "$f" ] || continue
   [ -n "$(tail -c 1 "$f")" ] && printf '\n' >> "$f"
done

for f in PKG mvpkg.json LICENSE README.md; do
   [ -f "$SRC/$f" ] && cp "$SRC/$f" "$ACCT/"
done
echo "build-pkg: staged http-curl as $ACCT/"
