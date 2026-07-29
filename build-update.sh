#!/bin/bash

# Define the src directory
src_directory="./src"

fetch_tar() {
  local url="$1"
  local name="$2"
  rm -rf src/"${name}"
  curl -sL "${url}" | tar -xvC src -s ";^[^/]*;${name};"
}

fetch_libplacebo() {
  local url="https://code.videolan.org/videolan/libplacebo.git"
  rm -rf src/libplacebo
  git -C src clone --depth 1 --recurse-submodules=3rdparty/{fast_float,jinja,markupsafe} "${url}"
}

fetch_libunibreak() {
  local version="7.0"
  local url="https://github.com/adah1972/libunibreak/releases/download/libunibreak_${version//./_}/libunibreak-${version}.tar.gz"
  fetch_tar "${url}" libunibreak
}

fetch_mpv() {
  local url="https://github.com/mpv-player/mpv.git"
  rm -rf src/mpv
  git -C src clone --single-branch --no-tags "${url}"
}

fetch_opus() {
  local url="https://github.com/xiph/opus.git"
  rm -rf src/opus
  git -C src clone --single-branch "${url}"

  local model
  cd src/opus
  model="$(sed -nE 's;^dnn/download_model\.sh "(.+)"$;\1;p' autogen.sh)"
  echo "dnn model checksum: '${model}'"
  ./dnn/download_model.sh "${model}"
  cd -
}

fetch_libdvdread() {
  local url="https://code.videolan.org/videolan/libdvdread/-/archive/master/libdvdread-master.tar.bz2"
  fetch_tar "${url}" libdvdread
}

fetch_libbluray() {
  local url="https://code.videolan.org/videolan/libbluray.git"
  rm -rf src/libbluray
  git -C src clone --depth 1 --recurse-submodules "${url}"
}

fetch_libplacebo &
P_libplacebo=$!

fetch_libunibreak &
P_libunibreak=$!

fetch_mpv &
P_mpv=$!

fetch_opus &
P_opus=$!

fetch_libdvdread &
P_libdvdread=$!

fetch_libbluray &
P_libbluray=$!

wait $P_libplacebo $P_libunibreak $P_mpv $P_opus $P_libdvdnav $P_libdvdread $P_libbluray;

# Iterate through each subdirectory
for dir in "$src_directory"/*; do
    if [ -d "$dir" ]; then
        if [ -d "$dir/.git" ]; then
            echo "Updating $dir"
            git -C "$dir" pull --force
        else
            echo "$dir is not a Git repository"
        fi
    fi
done


if [ -d "$ZSH_COMPLETIONS/_mpv" ]; then
  rm -rf "$ZSH_COMPLETIONS/_mpv"
fi

cp "$src_directory"/mpv/etc/_mpv.zsh "$ZSH_COMPLETIONS"/_mpv
