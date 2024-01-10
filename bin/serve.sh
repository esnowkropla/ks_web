#! /bin/bash

set -euf -o pipefail

mix generate 2>/dev/null
caddy file-server --listen :4000 --root public/
rm -r public/
