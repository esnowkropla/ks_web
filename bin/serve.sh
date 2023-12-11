#! /bin/bash

set -euf -o pipefail

# mix generate
caddy file-server --listen :4000 --root public/
rm -r public/
