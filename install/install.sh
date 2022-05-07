#!/bin/sh

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log" >&2)

script_name="$(basename "$0")"
dotfiles_dir="$(
    cd "$(dirname "$0")"
    pwd
)"
cd "$dotfiles_dir"

copy() {
    orig_file="$dotfiles_dir/$1"
    dest_file="/$1"

    mkdir -p "$(dirname "$orig_file")"
    mkdir -p "$(dirname "$dest_file")"

    rm -rf "$dest_file"

    cp -R "$orig_file" "$dest_file"
    echo "$dest_file <= $orig_file"
}

copy "etc/ssh/sshd_config.d/10-oliverdding.conf"
copy "etc/sudoers.d/override"
copy "etc/yum.repos.d/docker-ce.repo"
copy "etc/yum.repos.d/kubernetes.repo"
copy "etc/environment"
copy "etc/hostname"
copy "etc/locale.conf"
copy "etc/motd"

timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
hwclock -w
localectl set-locale LANG=en_US.UTF-8
localectl set-locale LANGUAGE=en_US.UTF-8

yum -y fish
yum -y install kubectl
yum -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

dnf -y copr enable luminoso/k9s
dnf -y copr enable atim/zoxide
dnf -y install k9s zoxide

chsh -s /bin/fish

mkdir -p ~/.local/bin
curl https://raw.githubusercontent.com/birdayz/kaf/master/godownloader.sh | BINDIR=$HOME/.local/bin bash
curl -s -L https://get.helm.sh/helm-v2.15.2-linux-amd64.tar.gz | tar -xzf - -C ~/.local/bin && mv ~/.local/bin/linux-amd64/helm /root/.local/bin/helm2 && mv ~/.local/bin/linux-amd64/tiller ~/.local/bin && rm -rf ~/.local/bin/linux-amd64
curl -s -L https://get.helm.sh/helm-v3.8.2-linux-amd64.tar.gz | tar -xzf - -C ~/.local/bin && mv ~/.local/bin/linux-amd64/helm /root/.local/bin/helm3 && rm -rf ~/.local/bin/linux-amd64
curl -s -L https://github.com/neovim/neovim/releases/latest/download/nvim.appimage -o ~/.local/bin/nvim
curl -s -L https://github.com/junegunn/fzf/releases/download/0.30.0/fzf-0.30.0-linux_amd64.tar.gz | tar -xzf - -C ~/.local/bin
curl -s -L https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz | tar -xzf - -C ~/.local/bin && mv ~/.local/bin/krew-linux_amd64 ~/.local/bin/kubectl-krew && rm -f ~/.local/bin/LICENSE

chown root:root ~/.local/bin/*
chmod 755 ~/.local/bin/*

export PATH=$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.krew/bin:$PATH

kubectl krew update
kubectl krew install ns ctx

curl -s "https://get.sdkman.io" | bash
source "/root/.sdkman/bin/sdkman-init.sh"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -q -y --default-host x86_64-unknown-linux-gnu --no-modify-path --default-toolchain nightly --profile default --component llvm-tools-preview clippy rust-src
cargo install starship ripgrep bottom exa git-delta xplr gping hexyl procs bat
