#!/bin/bash
#
# nvim_storage_usage.sh
# Reports disk space used by the Neovim config, plugins (lazy.nvim), and
# Mason-installed tools/LSPs/formatters/linters.

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

config_dir="$HOME/.config/nvim"
data_dir="$HOME/.local/share/nvim"
state_dir="$HOME/.local/state/nvim"
cache_dir="$HOME/.cache/nvim"

print_size() {
  local path="$1"
  local name="$2"
  if [ -e "$path" ]; then
    du -sh "$path" 2>/dev/null | awk -v name="$name" -v path="$path" '{printf "%-8s %-10s %s\n", $1, name, path}'
  else
    printf "%-8s %-10s %s (not found)\n" "0" "$name" "$path"
  fi
}

info "Neovim storage usage"
echo

print_size "$config_dir" "config"
print_size "$data_dir/lazy" "plugins"
print_size "$data_dir/mason" "mason"
print_size "$data_dir" "data"
print_size "$state_dir" "state"
print_size "$cache_dir" "cache"

echo
total=$(du -sch "$config_dir" "$data_dir" "$state_dir" "$cache_dir" 2>/dev/null | awk 'END{print}' | grep total)
success "Total: ${total%%$'\t'*}"
