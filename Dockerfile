FROM ocaml/opam:ubuntu-16.04_ocaml-4.03.0
RUN opam remote add dev git://github.com/mirage/mirage-dev && opam update -uy
RUN opam depext -uiyvj 4 irmin-unix cmdliner astring fmt logs
RUN opam search org:mirage -s | xargs -n 1 echo > repos_raw.txt
RUN echo alcotest ansi-parse anycache arp asn1-combinators astring base64 charrua-unix cmdliner cow cowabloga cpuid dockerfile duration ezjsonm ezxmlm hex hkdf irc-client integers jekyll-format logs logs-syslog lwt magic-mime lru-cache ocb-stubblr ocplib-endian opam-file-format otr owl parse-argv pcap-format angstrom session webmachine datakit vpnkit webbrowser xenstore  >> repos_raw.txt
RUN sort -u repos_raw.txt > repos.txt
COPY scripts/clone.sh /home/opam/clone.sh
RUN sudo chmod a+x /home/opam/clone.sh
RUN /home/opam/clone.sh
RUN sudo apt-get update && sudo apt-get -y install python-matplotlib
RUN opam pin add -y git-delve git://github.com/avsm/git-delve
RUN opam config exec -- git-delve -d _repos
