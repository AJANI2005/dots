CONFIG=$HOME/.config/mango/config.conf

read -r choice < <(
  awk -F'[=,]' '/^(bind|mousebind)=/ {
    cmd = $4
    for (i = 5; i <= NF; i++)
      cmd = cmd "," $i

    printf "%s + %s  ->  %s\n", $2, $3, cmd
  }' "$CONFIG" |
  fzf
)
