#!/bin/sh
# pstack の /statechart が java の代わりに呼ぶ (~/.claude/settings.json の env.JAVA)。
# /statechart は TLC 1.7.4 の出力を前提にしているので、tla-ts に 1.7.4 の挙動を再現させる。
exec "$HOME/.volta/bin/tla-ts" -Dtla-ts.tlc=1.7.4 "$@"
