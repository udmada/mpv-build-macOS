#!/bin/bash

# Define the src directory
src_directory="./src"

fetch_libplacebo() {
  local url="https://code.videolan.org/videolan/libplacebo.git"
  rm -rf src/libplacebo
  git -C src clone --single-branch --no-tags "${url}"
  git -C src/libplacebo submodule update --init 3rdparty/{fast_float,jinja,markupsafe}
}

fetch_libunibreak() {
  local version="6.1"
  local url="https://github.com/adah1972/libunibreak/releases/download/libunibreak_${version//./_}/libunibreak-${version}.tar.gz"
  rm -rf src/libunibreak
  curl -sL "${url}" | tar -xvC src -
  mv -v src/libunibreak-"${version}" src/libunibreak
}

fetch_mpv() {
  local url="https://github.com/mpv-player/mpv.git"
  rm -rf src/mpv
  git -C src clone --single-branch --no-tags "${url}"
}

fetch_opus() {
  local version="1.5.2"
  local url="https://downloads.xiph.org/releases/opus/opus-${version}.tar.gz"
  rm -rf src/opus
  curl -sL "${url}" | tar -xvC src -
  mv -v src/opus-"${version}" src/opus
}

fetch_libdvdnav() {
  local version="6.1.1"
  local url="https://download.videolan.org/pub/videolan/libdvdnav/${version}/libdvdnav-${version}.tar.bz2"
  rm -rf src/libdvdnav
  curl -sL "${url}" | tar -xvC src -
  mv -v src/libdvdnav-"${version}" src/libdvdnav
}

fetch_libplacebo &
P_libplacebo=$!

fetch_libunibreak &
P_libunibreak=$!

fetch_mpv &
P_mpv=$!

fetch_opus &
P_opus=$!

fetch_libdvdnav &
P_libdvdnav=$!

wait $P_libplacebo $P_libunibreak $P_mpv $P_opus $P_libdvdnav;

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