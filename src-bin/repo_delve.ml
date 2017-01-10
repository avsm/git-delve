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

let store_config = Irmin_mem.config ()
let task s = Irmin.Task.create ~date:0L ~owner:"Server" s
let repo _ = Store.Repo.create store_config

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
    
let main root =
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

let setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ())

let run_lwt git_dir () =
  (* Determine which repositories to clone *)
  Unix.chdir git_dir;
  Lwt_unix.files_of_directory "." |>
  Lwt_stream.iter_s (fun dir ->
    match dir with
    | "." | ".." -> Lwt.return_unit
    | dir when Sys.is_directory dir -> main dir
    | _ -> Lwt.return_unit) |>
  Lwt_main.run

open Cmdliner

let setup_log =
  Term.(const setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let git_dir =
  let doc = "Directory with Git checkouts" in
  Arg.(required & opt (some dir) None & info ["d"; "repo-directory"] ~docv:"REPO_DIRECTORY" ~doc)

let main () =
  match Term.(eval (const run_lwt $ git_dir $ setup_log, Term.info "irmin-code-scry")) with
  | `Error _ -> exit 1
  | _ -> exit (if Logs.err_count () > 0 then 1 else 0)

let () = main ()
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
