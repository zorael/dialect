#!/bin/bash

set -uexo pipefail

install_deps() {
    sudo apt update
    sudo apt install -y apt-transport-https

    sudo wget https://netcologne.dl.sourceforge.net/project/d-apt/files/d-apt.list \
        -O /etc/apt/sources.list.d/d-apt.list
    sudo apt update --allow-insecure-repositories

    # fingerprint 0xEBCF975E5BA24D5E
    sudo apt install -y --allow-unauthenticated --reinstall d-apt-keyring
    sudo apt update
    sudo apt install -y dmd-compiler dub

    #curl -fsS --retry 3 https://dlang.org/install.sh | bash -s ldc
}

build() {
    local dubArgs="--compiler=$1 --arch=$2"

    time dub $dubArgs test

    time dub $dubArgs build -b debug
    time dub $dubArgs build -b debug -c twitch
    time dub $dubArgs build -b debug -c dev

    time dub $dubArgs build -b plain
    time dub $dubArgs build -b plain -c twitch
    time dub $dubArgs build -b plain -c dev

    time dub $dubArgs build -b release
    time dub $dubArgs build -b release -c twitch
    time dub $dubArgs build -b release -c dev

    time dub $dubArgs build -b debug :defs
    time dub $dubArgs build -b debug :defs -c twitch

    time dub $dubArgs build -b debug :assertgen
    time dub $dubArgs build -b plain :assertgen
    time dub $dubArgs build -b release :assertgen
}

# execution start

case "$1" in
    install-deps)
        install_deps;

        dub --version
        dmd --version
        #ldc --version
        ;;
    build)
        time build dmd x86
        time build dmd x86_64
        #time build ldc x86_64
        ;;
    *)
        echo "Unknown command: $1";
        exit 1;
        ;;
esac

exit 0
