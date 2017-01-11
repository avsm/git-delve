(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

val t : start_year:int -> start_month:int -> end_year:int -> end_month:int -> Ptime.t list

val find_entry : Ptime.t -> (Ptime.t * 'a) list -> 'a option
val replace_entry : Ptime.t -> 'a -> (Ptime.t * 'a) list -> (Ptime.t * 'a) list
val incr_entry : Ptime.t -> (Ptime.t * int) list -> (Ptime.t * int) list

val cumulative_time :
  ('a -> 'b -> 'a) -> 'a -> (Ptime.t * 'b) list -> (Ptime.t * 'a) list

module NearestTime : sig
  include Map.S with type key = Ptime.t
  val find_last_updated : key -> 'a t -> key * 'a 
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

