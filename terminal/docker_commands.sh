#!/bin/bash -e

docker_prune_all() {
  docker image prune --all --force
  docker container prune --force
  docker builder prune --all --force
  docker volume prune --all --force
  docker system prune --all --force
}
