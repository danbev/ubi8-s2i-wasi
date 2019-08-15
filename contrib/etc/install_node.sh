#!/bin/bash

set -ex

INSTALL_PKGS="nss_wrapper python2"
yum install --disableplugin=subscription-manager -y --setopt=tsflags=nodocs ${INSTALL_PKGS}
export PYTHON=`which python2`

### Install clang
mkdir /llvm-dist
pushd /llvm-dist
gzip -dc /llvm-dist.tar.gz | tar xvf - --strip 1
cp -r bin/* /bin
mkdir /include
cp -r include/* /include
cp -r lib/* /lib
mkdir /libexec
cp -r libexec/* /libexec
mkdir /share
cp -r share/* /share
popd

### Install rustup (includes cargo)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
chmod 744 rustup.sh
./rustup.sh -y

export PATH=$HOME/.cargo/bin:$PATH

### Install Wasmtime
pushd /opt
git clone --recurse-submodules https://github.com/CraneStation/wasmtime.git
cd wasmtime
cargo build --release
cargo install --path .

echo $HOME
export PATH=/opt/app-root/src/.cargo/bin:$PATH
popd
