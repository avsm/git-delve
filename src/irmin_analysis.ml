(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

open Lwt.Infix
open Astring

module Store = Irmin_unix.Irmin_git.FS(Irmin.Contents.String)(Irmin.Ref.String)(Irmin.Hash.SHA1)
module Sync = Irmin.Sync(Store)
module Topological = Graph.Topological.Make(Store.History)

let src = Logs.Src.create "logs" ~doc:"Logs"
module Log = (val Logs.src_log src : Logs.LOG)

let task s = Irmin.Task.create ~date:0L ~owner:"Server" s

let num_lines =
  let nl = String.Sub.v "\n" in
  fun buf ->
  String.Sub.v buf |> fun buf ->
  String.Sub.cuts ~sep:nl buf |>
  List.length

let count_lines_in_store t =
  let lines = ref 0 in
  Store.iter t (fun _k v ->
    v () >|= fun v ->
    lines := !lines + (num_lines v)
  ) >>= fun () ->
  Lwt.return !lines
    
let count_repo root =
  let open Irmin_unix in
  Irmin_git.config ~root ~bare:false () |> fun config ->
  Store.Repo.create config >>= fun cfg ->
  Store.of_branch_id task "master" cfg >>= fun t ->
  Store.history (t "history") >>= fun history ->
  let commits = Topological.fold (fun b acc -> b :: acc) history [] in
  Lwt_list.iter_s (fun c ->
    let hash = Irmin.Hash.SHA1.to_hum c in
    let repo = Store.repo (t "repo") in
    Store.Repo.task_of_commit_id repo c >>= fun task ->
    Store.of_commit_id Irmin.Task.none c repo >>= fun store ->
    let owner = Irmin.Task.owner task in
    count_lines_in_store (store ()) >>= fun lines ->
    Printf.printf "%s %s \"%s\" %d\n%!" root hash owner lines;
    Lwt.return_unit
  ) commits

(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  ---------------------------------------------------------------------------*)
