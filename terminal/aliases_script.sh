# Auto-create aliases for each folder within a given directory
# Usage: generate_alias ~/src/personal/

generate_alias() {
  local folder="$1"
  [[ -d "$folder" ]] || { echo "Directory not found: $folder"; return 1; }

  # Ensure trailing slash
  [[ "$folder" == */ ]] || folder="$folder/"

  echo "Auto alias: $folder"
  for f in "$folder"*/; do
    [[ -d "$f" ]] || continue
    local name
    name=$(basename "$f" | tr '[:upper:]' '[:lower:]')
    # Skip names that aren't valid alias names
    [[ "$name" =~ ^[a-z0-9_-]+$ ]] || continue
    alias "$name=cd $f"
  done
}
