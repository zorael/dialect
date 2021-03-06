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
    sudo apt install -y --allow-unauthenticated dmd-compiler dub

    #curl -fsS --retry 3 https://dlang.org/install.sh | bash -s ldc

    #git clone https://github.com/zorael/lu.git
    #dub add-local lu
}

build() {
    local dubArgs="--compiler=$1 --arch=$2"

    time dub test $dubArgs

    time dub build $dubArgs -b debug
    time dub build $dubArgs -b debug -c dev

    time dub build $dubArgs -b plain
    time dub build $dubArgs -b plain -c dev

    time dub build $dubArgs -b release
    time dub build $dubArgs -b release -c dev

    time dub build $dubArgs -b debug :assertgen
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
        #time build dmd x86  # CircleCI does not seem to have the needed libs
        time build dmd x86_64
        #time build ldc x86_64
        ;;
    *)
        echo "Unknown command: $1";
        exit 1;
        ;;
esac

exit 0
