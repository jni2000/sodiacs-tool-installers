#!/bin/bash

# Exit immediately if any command fails
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/workspace/software-scanning"
REPO_DIR="$TARGET_DIR/cbomkit-theia"
REPO_URL="git@github.com:jni2000/cbomkit-theia.git"
MIN_GO_MINOR=25

# github.com/owner/repo, so SSH and HTTPS remotes for one repo compare equal.
canonical_github_repo() {
  local url="$1"
  local prefix

  url="${url%/}"
  url="${url%.git}"
  for prefix in ssh:// git:// https:// http:// git@; do
    url="${url#"$prefix"}"
  done
  url="${url/:/\/}"
  printf '%s\n' "$url" | tr '[:upper:]' '[:lower:]'
}

# "go version go1.27.1 linux/amd64" -> 1.27.1. Empty when the binary does not run.
go_release_version() {
  "$1" version 2>/dev/null | awk '{print $3}' | sed -n 's/^go//p' || true
}

# True when $1 is a strictly newer dotted version than $2.
version_is_newer() {
  local candidate="$1"
  local current="$2"
  local newest

  if [ "$candidate" = "$current" ]; then
    return 1
  fi
  newest=$(printf '%s\n%s\n' "$current" "$candidate" | sort -V | tail -1)
  if [ "$newest" = "$candidate" ]; then
    return 0
  fi
  return 1
}

minor_version() {
  printf '%s\n' "$1" | cut -d. -f2
}

# update_go.sh installs into /usr/local/go without changing this process.
# Use the newest Go 1.25+ from that install or from the go already on PATH.
use_newest_go() {
  local candidate path_go version minor best_bin best_version
  best_bin=""
  best_version=""

  path_go=$(command -v go 2>/dev/null || true)
  for candidate in /usr/local/go/bin/go "$path_go"; do
    if [ -z "$candidate" ] || [ ! -x "$candidate" ]; then
      continue
    fi

    version=$(go_release_version "$candidate")
    minor=$(minor_version "$version")
    case "$minor" in
      ''|*[!0-9]*) continue ;;
    esac
    if [ "$minor" -lt "$MIN_GO_MINOR" ]; then
      continue
    fi
    if [ -z "$best_version" ] || version_is_newer "$version" "$best_version"; then
      best_version=$version
      best_bin=$candidate
    fi
  done

  if [ -z "$best_bin" ]; then
    echo "Error: no Go 1.${MIN_GO_MINOR} or newer is available after update_go.sh."
    exit 1
  fi

  # Only "go" is shadowed, so git and curl keep their original paths.
  GO_SHIM_DIR=$(mktemp -d)
  trap 'rm -rf "$GO_SHIM_DIR"' EXIT
  ln -s "$best_bin" "${GO_SHIM_DIR}/go"
  export PATH="${GO_SHIM_DIR}:$PATH"
  hash -r
  echo "Using $("$best_bin" version)"
}

require_expected_origin() {
  local origin_url

  if ! origin_url=$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null); then
    echo "Error: $REPO_DIR has no origin remote."
    exit 1
  fi
  if [ "$(canonical_github_repo "$origin_url")" != "$(canonical_github_repo "$REPO_URL")" ]; then
    echo "Error: $REPO_DIR origin is ${origin_url}, expected ${REPO_URL}."
    exit 1
  fi
}

prepare_repo() {
  mkdir -p "$TARGET_DIR"

  if [ -d "$REPO_DIR/.git" ]; then
    require_expected_origin
    echo "Updating existing checkout at $REPO_DIR"
    git -C "$REPO_DIR" fetch origin
    git -C "$REPO_DIR" checkout -f -B main origin/main
    return
  fi

  if [ -e "$REPO_DIR" ]; then
    echo "Error: $REPO_DIR exists but is not a git checkout."
    exit 1
  fi

  git clone "$REPO_URL" "$REPO_DIR"
  git -C "$REPO_DIR" checkout main
}

build_cbomkit() {
  cd "$REPO_DIR"
  # grpc v1.79.3 calls http2.TrailerPrefix. x/net v0.54.0 omits that symbol
  # under Go 1.27; v0.55.0 restores it.
  go get golang.org/x/net@v0.55.0
  go mod tidy
  go build
}

chmod +x "$SCRIPT_DIR/update_go.sh"
"$SCRIPT_DIR/update_go.sh"
use_newest_go
prepare_repo
build_cbomkit
