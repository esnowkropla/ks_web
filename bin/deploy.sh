#! /bin/bash

echo "Rebuilding site..."
rm -r "esnowkropla.github.io/*"
mix generate esnowkropla.github.io
cd esnowkropla.github.io || exit
git add .
git commit -am "Auto-deploy"
git push origin master
