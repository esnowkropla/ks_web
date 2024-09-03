#! /bin/bash

set -euf -o pipefail

trap 'rm -r public/' SIGINT

mix web.generate 2>/dev/null
caddy start
inotifywait -mI -r -e CLOSE_WRITE assets/ templates/ lib/ | while read -r _path _event _file;
do
  mix web.generate 2>/dev/null
done
