#!/bin/sh -ex

docker build -t local-build .
eval `ssh-agent -s`
chmod 600 deploy_git_delve
ssh-add deploy_git_delve
mkdir html
for i in contribs.pdf commits.pdf loc.pdf files.txt; do
  docker run local-build cat /home/opam/src/scripts/$i > html/$i
done
cd html
git init
git checkout -b gh-pages
git add *
git commit -m sync -a
git remote add origin git@github.com:avsm/git-delve
git push -u origin +gh-pages
