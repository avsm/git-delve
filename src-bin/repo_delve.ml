(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

open Lwt.Infix
open Astring

let main dir =
  Irmin_analysis.repo_commits dir >|=
  List.iter (fun (hash, owner, date) ->
    Printf.printf "%s %s %S %Lu\n%!" dir hash owner date

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
