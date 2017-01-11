(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

open Lwt.Infix
open Astring

module Store = Irmin_unix.Irmin_git.FS(Irmin.Contents.String)(Irmin.Ref.String)(Irmin.Hash.SHA1)
module Sync = Irmin.Sync(Store)
(*
module Mem_Store = Irmin_unix.Irmin_git.Memory(Irmin.Contents.String)(Irmin.Ref.String)(Irmin.Hash.SHA1)
module Mem_sync = Irmin.Sync(Mem_Store)
*)
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

let t = Date_range.t

let count_lines_in_store t =
  let lines = ref 0 in
  Store.iter t (fun _k v ->
    v () >|= fun v ->
    lines := !lines + (num_lines v)
  ) >>= fun () ->
  Lwt.return !lines

let map_repo fn root =
  let open Irmin_unix in
  Irmin_git.config ~root ~bare:false () |> fun config ->
  Store.Repo.create config >>= fun cfg ->
  Store.master task cfg >>= fun tt ->
  let disk_store = Irmin.remote_store (module Store) (tt "remote") in
(*
  Mem_Store.Repo.create config >>= fun mem_cfg ->
  Mem_Store.master task mem_cfg >>= fun mem_tt ->
  let mem_store = Irmin.remote_store (module Mem_Store) (mem_tt "remote") in
  prerr_endline "starting pull";
  Mem_sync.pull (mem_tt "pull") disk_store `Update >>= fun _ ->
  prerr_endline "starting done pull";
*)
  Store.of_branch_id task "master" cfg >>= fun t ->
  Store.history (t "history") >>= fun history ->
  let commits = Topological.fold (fun b acc -> b :: acc) history [] in
  Lwt_list.map_s (fun commit ->
    let repo = Store.repo (t "repo") in
    Store.Repo.task_of_commit_id repo commit >>= fun task ->
    Store.of_commit_id Irmin.Task.none commit repo >>= fun store ->
    fn store task commit
  ) commits

let count_repo_loc root =
  map_repo (fun store task commit ->
    Printf.eprintf ".%!";
    count_lines_in_store (store ()) >|= fun lines ->
    let date =
      Irmin.Task.date task |>
      Int64.to_float |>
      Ptime.of_float_s |>
      function None -> failwith "invalid date" | Some x -> x in
    date, lines
  ) root >|=
  let module NT = Date_range.NearestTime in
  List.fold_left (fun acc (k,v) -> NT.add k v acc) NT.empty

let repo_loc_for_range ~start_year ~start_month ~end_year ~end_month root =
  Printf.eprintf "Processing %s: %!" root;
  count_repo_loc root >|= fun t ->
  Printf.eprintf "%d commits\n%!" (Date_range.NearestTime.cardinal t);
  let range = Date_range.t ~start_year ~start_month ~end_year ~end_month in
  List.map (fun d -> 
    try
      let _,v = Date_range.NearestTime.find_last_updated d t in
      d,v
    with Not_found -> d,0
  ) range

let repo_commits =
  map_repo (fun store task commit ->
    let owner = Irmin.Task.owner task in
    let date = Irmin.Task.date task in
    let hash = Irmin.Hash.SHA1.to_hum commit in
    Lwt.return (hash,owner,date)
  ) 
 
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
