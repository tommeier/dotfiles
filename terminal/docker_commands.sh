# =============================================================================
# Docker Commands
# =============================================================================

# Common shortcuts
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias dlog='docker logs -f'
alias dex='docker exec -it'
alias dstop='docker stop $(docker ps -q)'

# Docker Compose
alias dc='docker compose'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcb='docker compose build'
alias dcr='docker compose run --rm'
alias dcl='docker compose logs -f'
alias dcps='docker compose ps'

# Interactive container shell
dsh() {
  docker exec -it "$1" /bin/sh
}

dbash() {
  docker exec -it "$1" /bin/bash
}

# =============================================================================
# Destructive Commands (with confirmation)
# =============================================================================

docker_prune_all() {
  echo "⚠️  This will remove ALL:"
  echo "   - Containers (running and stopped)"
  echo "   - Images (including unused)"
  echo "   - Volumes (all data will be lost)"
  echo "   - Build cache"
  echo ""
  read "resp?Are you sure? [y/N] "
  [[ "$resp" =~ ^[Yy]$ ]] || { echo "Aborted."; return 1; }

  echo "Pruning containers..."
  docker container prune --force
  echo "Pruning images..."
  docker image prune --all --force
  echo "Pruning volumes..."
  docker volume prune --force
  echo "Pruning builder cache..."
  docker builder prune --all --force
  echo "Final system prune..."
  docker system prune --all --force
  echo "✅ Docker cleanup complete."
}
