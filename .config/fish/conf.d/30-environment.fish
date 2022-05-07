set -gx GOPATH "$HOME/.local/share/go"
set -gx KUBECONFIG (echo (ls ~/.kube/config.d/* 2>/dev/null) | sed 's/ /:/g')
