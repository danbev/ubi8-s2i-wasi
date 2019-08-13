#!/bin/bash

set -ex

INSTALL_PKGS="nss_wrapper python2"
yum install --disableplugin=subscription-manager -y --setopt=tsflags=nodocs ${INSTALL_PKGS}
export PYTHON=`which python2`

### Install clang
pushd /
gzip -dc llmv-dist.tar.gz | tar  xvf - --strip 1
popd

### Install rustup (includes cargo)
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -- -y

### Install Wasmtime
#pushd /opt
#git clone --recurse-submodules https://github.com/CraneStation/wasmtime.git
#cd wamtime
#cargo build --release
#cargo install 
#popd
