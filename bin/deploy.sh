#! /bin/bash

echo "Rebuilding site..."

pushd esnowkropla.github.io || exit
rm -r -- *
popd || exit

mix generate esnowkropla.github.io

pushd esnowkropla.github.io || exit
git add .
git commit -am "Auto-deploy"
git push origin master
sub_hash=$(git rev-parse --short HEAD)
popd || exit
git add .
git commit -am "Deploying $sub_hash in submodule esnowkropla.github.io"
