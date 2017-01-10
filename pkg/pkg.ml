#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let () =
  Pkg.describe "git-delve" @@ fun c ->
  Ok [ Pkg.mllib "src/git-delve.mllib";
       Pkg.bin ~dst:"repo-delve" "src-bin/repo_delve" ]
