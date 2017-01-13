(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

(* Turn a repo name into a category name.  This will eventually be read
   from a file and is only hardcoded here temporarily *)

type t =
  | Driver
  | Core
  | Web
  | Protocol
  | Sec 
  | Tool
  | Storage
  | Unknown of string

let to_int = function
  | Core -> 1
  | Driver -> 2
  | Protocol -> 3
  | Storage -> 4
  | Sec -> 5
  | Web -> 6
  | Tool -> 7
  | Unknown _ -> 8

let to_string = function
  | Driver -> "driver"
  | Core -> "core"
  | Web -> "web"
  | Protocol -> "protocol"
  | Sec -> "security"
  | Tool -> "tool"
  | Storage -> "storage"
  | Unknown x -> "unknown:" ^ x

let classify repo =
  (* Strip any extension *)
  let repo = Fpath.(v repo |> split_ext |> fst |> to_string) in
  match repo with
  |"cdrom" -> Driver
  |"mirage-clock" -> Core
  |"ocaml-dns" -> Protocol
  |"ocaml-wamp" -> Web
  |"cohttp" -> Web
  |"mirage-console" -> Core
  |"ocaml-dnscurve" -> Sec
  |"ocaml-websocket" -> Web
  |"cowabloga" -> Web
  |"mirage-console-solo5" -> Driver
  |"ocaml-dockerfile" -> Tool
  |"ocaml-x509" -> Sec
  |"datakit" -> Storage
  |"ocaml-evtchn" -> Driver
  |"ocaml-xen-block-driver" -> Driver
  |"depyt" -> Core
  |"mirage-entropy" -> Core
  |"ocaml-fat" -> Storage
  |"ocaml-xen-lowlevel-libs" -> Driver
  |"mirage-net-solo5" -> Driver
  |"dyntype" -> Core
  |"mirage-fs" -> Storage
  |"ocaml-fd-send-recv" -> Driver
  |"ocaml-xenstore-clients" -> Tool
  |"ezjsonm" -> Web
  |"mirage-fs-unix" -> Driver
  |"ocaml-github" -> Web
  |"omd" -> Web
  |"ezxmlm" -> Web
  |"mirage-tcpip" -> Protocol
  |"ocaml-ipaddr" -> Protocol
  |"opam-mirror" -> Tool
  |"io-page" -> Core
  |"ocaml-mbr" -> Storage
  |"orm" -> Storage
  |"mirage-xen-minios" -> Driver
  |"ocaml-minima-theme" -> Web
  |"parse-argv" -> Core
  |"irmin" -> Storage
  |"mirage" -> Core
  |"ocaml-nocrypto" -> Sec
  |"shared-block-ring" -> Driver
  |"jekyll-format" -> Web
  |"mirari" -> Tool
  |"ocaml-pcap" -> Protocol
  |"shared-memory-ring" -> Driver
  |"libvhd" -> Storage
  |"nbd" -> Storage
  |"ocaml-qcow" -> Storage
  |"tcpip" -> Protocol
  |"oasis" -> Tool
  |"ocaml-qmp" -> Tool
  |"tls" -> Sec
  |"mirage-block-ramdisk" -> Driver
  |"ocaml-asn1-combinators" -> Sec
  |"ocaml-rpc" -> Protocol
  |"travis-senv" -> Tool
  |"mirage-block-solo5" -> Driver
  |"ocaml-cohttp" -> Web
  |"ocaml-sodium" -> Sec
  |"vhd-tool" -> Storage
  |"mirage-block-xen" -> Driver
  |"ocaml-conduit" -> Protocol
  |"ocaml-tar" -> Storage
  |"xen-api-client" -> Tool
  |"mirage-block" -> Storage
  |"ocaml-cow" -> Web
  |"ocaml-tls" -> Sec
  |"xen-disk" -> Storage
  |"mirage-channel" -> Protocol
  |"ocaml-crunch" -> Tool
  |"ocaml-tuntap" -> Driver
  |"xenbigarray" -> Core
  |"mirage-ci" -> Tool
  |"ocaml-cstruct" -> Core
  |"ocaml-uri" -> Web
  |"ocaml-ctypes" -> Core
  |"ocaml-vhd" -> Storage
  |"alcotest" -> Tool
  |"angstrom" -> Protocol
  |"ansi-parse" -> Protocol
  |"arp" -> Protocol
  |"astring" -> Core
  |"charrua-client" -> Protocol
  |"charrua-unix" -> Protocol
  |"cmdliner" -> Core
  |"cpuid" -> Tool
  |"duration" -> Core
  |"logs" -> Core
  |"logs-syslog" -> Driver
  |"lwt" -> Core
  |"mirage-device" -> Core
  |"mirage-flow" -> Core
  |"mirage-kv" -> Core
  |"mirage-logs" ->  Core
  |"mirage-net" -> Protocol
  |"mirage-protocols" -> Protocol
  |"mirage-random" -> Core
  |"mirage-stack" -> Protocol
  |"mirage-time" -> Core
  |"ocaml-anycache" -> Storage
  |"ocaml-base64" -> Storage
  |"ocaml-hex" -> Storage
  |"ocaml-hkdf" -> Sec
  |"ocaml-integers" -> Core
  |"ocaml-irc-client" -> Protocol
  |"ocaml-lru-cache" -> Storage
  |"ocaml-magic-mime" -> Web
  |"ocaml-otr" -> Sec
  |"ocaml-session" -> Web
  |"ocaml-webmachine" -> Web
  |"ocaml-xenstore" -> Driver
  |"ocb-stubblr" -> Tool
  |"ocplib-endian" -> Core
  |"opam-file-format" -> Tool
  |"owl" -> Tool
  |"vpnkit" -> Protocol
  |"webbrowser" -> Web
  |"mirage-vnetif" -> Driver
  |"functoria" -> Core
  |"mirage-net-unix" -> Driver
  |"mirage-net-xen" -> Driver
  |"mirage-stdlib-random" -> Driver
  |"mirage-qubes" -> Driver
  |"ocaml-hvsock" -> Protocol
  |"randomconv" -> Core
  |"mirage-os-shim" -> Tool
  |"mirage-platform" -> Core
  |"ocaml-vchan" -> Protocol 
  |"mirage-solo5" -> Driver
  |"charrua-core" -> Protocol
  |"solo5" -> Driver
  |"ocaml-9p" -> Protocol
  |"mirage-bootvar-solo5" -> Core
  |"imaplet-lwt" -> Protocol
  |x -> Unknown x

let t x = classify x

let compare a b = compare (to_int a) (to_int b)

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

