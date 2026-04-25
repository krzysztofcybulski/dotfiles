# Make a dir and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Extract any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "Don't know how to extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# fzf-cd: jump anywhere under $HOME
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git . "${1:-$HOME}" | fzf +m) && cd "$dir"
}

# Route `git clone` from known hosts into ~/netflix or ~/personal.
git() {
  if [[ "$1" != "clone" ]]; then
    command git "$@"
    return
  fi

  local -a positionals
  local arg
  for arg in "${@:2}"; do
    [[ "$arg" == -* ]] || positionals+=("$arg")
  done
  if (( ${#positionals[@]} != 1 )); then
    command git "$@"
    return
  fi

  local url="${positionals[1]}"
  local target_root=""
  if [[ "$url" == *github.netflix.net* ]]; then
    target_root="$HOME/netflix"
  elif [[ "$url" == *github.com[:/]krzysztofcybulski/* ]]; then
    target_root="$HOME/personal"
  fi
  if [[ -z "$target_root" ]]; then
    command git "$@"
    return
  fi

  local repo="${url##*[/:]}"
  repo="${repo%.git}"
  local target="$target_root/$repo"

  printf 'Clone into %s? [Y/n] ' "$target"
  local reply
  read -r reply
  if [[ "$reply" == [Nn]* ]]; then
    command git "$@"
    return
  fi

  mkdir -p "$target_root"
  command git clone "${@:2}" "$target"
}
