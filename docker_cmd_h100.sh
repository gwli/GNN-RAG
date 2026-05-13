#!/usr/bin/env bash
set -euo pipefail

img="${IMG:-nvcr.io/nvidia/pytorch:20.10-py3}"
container_name="${CONTAINER_NAME:-gnn-rag-h100}"
host_repo="${HOST_REPO:-/raid/git/GNN-RAG}"
container_repo="${CONTAINER_REPO:-/git/GNN-RAG}"

if docker ps -a --format '{{.Names}}' | awk -v name="${container_name}" '$0 == name { found = 1 } END { exit found ? 0 : 1 }'; then
  docker stop "${container_name}" >/dev/null
fi

docker run \
  --gpus all \
  --privileged=true \
  --workdir "${container_repo}" \
  --name "${container_name}" \
  -e DISPLAY \
  --ipc=host \
  -d \
  --rm \
  -p 6332:8889 \
  -v "${host_repo}:${container_repo}" \
  "${img}" \
  sleep infinity

echo "Container ${container_name} is running."
echo "Open shell: docker exec -it ${container_name} /bin/bash"
echo "Stop: docker stop ${container_name}"
