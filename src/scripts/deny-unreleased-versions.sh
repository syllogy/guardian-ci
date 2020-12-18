matches=$(go mod graph | awk '{print $2}' | grep 'github.com/BishopFox' | grep -E -v 'v[0-9]+.[0-9]+.[0-9]+$' | grep -v groot || true); \
test -z "$matches" || (printf "\nfailing build as go.mod references unreleased library versions: \n%s\n" "$matches" >&2 && exit 1);

matches=$(grep -e '^replace' go.mod || true); \
test -z "$matches" || (printf "\nfailing build as go.mod contains replace statements: \n%s\n" "$matches" >&2 && exit 1);
