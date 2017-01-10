rm -rf _repos
mkdir -p _repos
cd _repos
for i in mirage tcpip tls cohttp irmin datakit; do
  opam source $i --dev-repo
done
