#!/usr/bin/env sh

set -e

KIND_VERSION_REQUIRED="0.10.0"
KIND_VERSION_CURRENT=$(kind --version)

command -v docker >/dev/null 2>&1 || { \
  echo "Docker is not installed."; \
  exit 1; \
}

[[ "$KIND_VERSION_CURRENT" = "kind version $KIND_VERSION_REQUIRED" ]] || { \
  echo "kind version mismatch. Please install kind $KIND_VERSION_REQUIRED"; \
  exit 1; \
}

command -v kubectl >/dev/null 2>&1 || { \
  echo "kubectl is not installed."; \
  exit 1; \
}

echo "All requirements are met."
