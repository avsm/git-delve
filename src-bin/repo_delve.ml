(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

open Lwt.Infix
open Astring

let with_range fn v =
  let start_month = 1 in
  let start_year = 2013 in
  let end_month = 12 in
  let end_year = 2016 in
  fn ~start_year ~start_month ~end_year ~end_month v

let main = with_range Irmin_analysis.repo_loc_for_range
let commits = with_range Irmin_analysis.repo_commits_for_range
let contribs = with_range Irmin_analysis.repo_contribs_for_range

let ptime_to_ts tm = Fmt.strf "%Ld" (Ptime.to_float_s tm |> Int64.of_float)

let merge_without_dup l1 l2 =
  List.fold_left (fun a b ->
    match List.mem b a with
    | true -> a  | false -> b::a
  ) l1 l2
    
let run_lwt git_dir mode () =
  (* Determine which repositories to clone *)
  Unix.chdir git_dir;
  let t =
    let st = Lwt_unix.files_of_directory "." in
    let st = Lwt_stream.filter_s (fun dir ->
      match dir with
      | "." | ".." -> Lwt.return_false
      | dir when Sys.is_directory dir -> Lwt.return_true
      | _ -> Lwt.return_false
    ) st in
    Lwt_stream.to_list st >>= fun dirs ->
    match mode with
    | `Scan ->
        List.iter (fun dir -> Printf.printf "%s -> %s\n%!" dir (Classify_repo.t dir)) dirs;
        Lwt.return_unit
    | `Loc ->
        Lwt_list.map_s (fun dir -> main dir >|= fun r -> dir, r) dirs >>= fun l ->
        let r = Irmin_analysis.combine_with_times (fun acc loc -> acc+loc) 0 l in
        List.iter (fun (repo, tms) ->
          List.iter (fun (tm, loc) ->
            Printf.printf "%s %s %d\n%!" repo (ptime_to_ts tm) loc) tms
        ) r;
        Lwt.return_unit
    | `Commit ->
        Lwt_list.map_s (fun dir -> commits dir >|= fun r -> dir, r) dirs >>= fun l ->
        let r = Irmin_analysis.combine_with_times (fun acc loc -> acc+loc) 0 l in
        List.iter (fun (repo, tms) ->
          List.iter (fun (tm, loc) ->
            Printf.printf "%s %s %d\n%!" repo (ptime_to_ts tm) loc) tms
        ) r;
        Lwt.return_unit
    | `Contrib ->
        Lwt_list.map_s (fun dir -> contribs dir >|= fun r -> dir, r) dirs >>= fun l ->
        let r = Irmin_analysis.combine_with_times (fun acc cbs ->
          merge_without_dup acc cbs) [] l in
        let r = List.map (fun (r,tms) ->
          let n = Date_range.cumulative_time merge_without_dup [] tms in
          let n2 = List.map (fun (tm,b) -> tm, (List.length b)) n in
          r, n2) r in
        List.iter (fun (repo, tms) ->
          List.iter (fun (tm, loc) ->
            Printf.printf "%s %s %d\n%!" repo (ptime_to_ts tm) loc) tms
        ) r;
        Lwt.return_unit
  in
  Lwt_main.run t

let setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ())

open Cmdliner

let setup_log =
  Term.(const setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let git_dir =
  let doc = "Directory with Git checkouts" in
  Arg.(required & opt (some dir) None & info ["d"; "repo-directory"] ~docv:"REPO_DIRECTORY" ~doc)

let mode =
  let doc = "Which analysis to run" in
  let choices = ["scan",`Scan; "loc",`Loc; "commit", `Commit; "contrib", `Contrib] in
  Arg.(value & pos 0 (enum choices) `Scan & info [] ~docv:"MODE" ~doc)

let main () =
  match Term.(eval (const run_lwt $ git_dir $ mode $ setup_log, Term.info "git-delve")) with
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
