(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

let t ~start_year ~start_month ~end_year ~end_month =
  let mk ~y ~m =
    match Ptime.of_date (y,m,1) with
    | None -> raise (Failure "invalid date")
    | Some x -> x
  in
  let rec fn acc (y,m) =
    match (y,m) with
    |y,m when y=start_year && m=start_month -> (mk ~y ~m :: acc) |> List.rev
    |y,1 -> fn (mk ~y ~m :: acc) (y-1,12)
    |y,m -> fn (mk ~y ~m :: acc) (y,m-1)
  in
  fn [] (end_year, end_month)

module NearestTime = struct
  include Map.Make(Ptime)

  let find_last_updated k m =
    match split k m with
    | l, Some v, _ -> (k,v)
    | l, None, _ -> max_binding l
end
 

 
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

