#!/bin/sh -e

for i in `cat repos.txt`; do
  devrepo=`opam show $i -f dev-repo`
  if [ "$devrepo" = "" ]; then
    echo Error: no dev repo found for $i
  else
    base=`basename $devrepo`
    echo cloning opam package: $i $devepo $base
    if [ ! -d $base ]; then
      git clone $devrepo $base
      echo $i > $base/mirage-opam-pkg.txt
    else
      echo $i >> $base/mirage-opam-pkg.txt
    fi
  fi
done
