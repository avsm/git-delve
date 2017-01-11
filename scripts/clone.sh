#!/bin/sh -e

mkdir -p _repos
for i in `cat repos.txt`; do
  devrepo=`opam show $i -f dev-repo`
  if [ "$devrepo" = "" ]; then
    echo Error: no dev repo found for $i
  else
    base=`basename $devrepo`
    echo cloning opam package: $i $devepo $base
    if [ ! -d _repos/$base ]; then
      git clone $devrepo _repos/$base
      echo $i > _repos/$base/mirage-opam-pkg.txt
    else
      echo $i >> _repos/$base/mirage-opam-pkg.txt
    fi
  fi
done
